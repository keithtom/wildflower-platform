module Workflow
  module Definition
    class Workflow
      class Publish < BaseService
        def initialize(workflow_definition_id)
          @workflow = ::Workflow::Definition::Workflow.find(workflow_definition_id)

          @process_stats = {
            added: 0,
            removed: 0,
            upgraded: 0,
            repositioned: 0,
            error_raised: false
          }
        end

        def run
          validate
          set_tracking_stats
          @workflow&.previous_version&.instances&.each do |workflow_instance|
            @dependency_creators = []
            @dependency_creates = {}

            begin
              ActiveRecord::Base.transaction do
                rollout_adds(workflow_instance)
                rollout_removes(workflow_instance)
                rollout_upgrades(workflow_instance)
                rollout_repositions(workflow_instance)
                rollout_dependencies # Create dependencies 

                workflow_instance.version = @workflow.version
                workflow_instance.definition = @workflow
                workflow_instance.save!
              end
            rescue Exception => e
              @process_stats[:error_raised] = true
              Rails.logger.error("Rolling out version changes from workflow definition id #{@workflow.id} to instance id #{workflow_instance.id}: ")
              Rails.logger.error("#{e.message},")
              Rails.logger.error(" for #{e.record.inspect}") if e.respond_to?(:record)
              Rails.logger.error(e.backtrace.join("\n"))
              Highlight::H.instance.record_exception(e)
              if Rails.env.production?
                SlackClient.chat_postMessage(channel: '#circle-platform', text: e.message, as_user: true)
              end
            end
          end
          finish_publish_stats

          return @process_stats
        end

        def validate
          if @workflow.published?
            raise PublishError.new("workflow id #{@workflow.id} is already published")
          end

          if @workflow.selected_processes.where.not(state: "replicated").count == 0
            raise PublishError.new("no changes made to the previous version of this workflow id: #{@workflow.id}")
          end
        end

        def set_tracking_stats
          @workflow.rollout_started_at = DateTime.now
          @workflow.save!

          # todo: probably need more stats
        end

        def rollout_adds(workflow_instance)
          @workflow.selected_processes.where(state: "added").each do |sp|
            previous_process_by_position = workflow_instance.processes.order(position: :desc).where("position < ?", sp.position).first
            if previous_process_by_position.nil? || previous_process_by_position.unstarted? || previous_process_by_position.started?
              process_instance = ::Workflow::Instance::Process::Create.run(sp.process, @workflow, workflow_instance)
              sp.process.workable_dependencies.where(workflow_id: @workflow.id).each do |dependency_definition|
                create_dependency_later(dependency_definition, workflow_instance, process_instance)
              end
              if sp.process.workable_dependencies.where(workflow_id: @workflow.id).empty?
                process_instance.prerequisites_met!
              end
              @process_stats[:added] += 1
            else
              Rails.logger.info("Previous process #{previous_process_by_position.id} has been finished. Therefore, the new process definition #{sp.process_id} will not be added to this rollout")
            end
            sp.process.published_at = DateTime.now
            sp.process.save!
          end
        end

        def rollout_removes(workflow_instance)
          @workflow.selected_processes.where(state: "removed").each do |sp|
            workflow_instance.processes.where(definition_id: sp.process_id, position: sp.previous_version&.position).each do |process_instance|
              if process_instance.unstarted?
                process_instance.workable_dependencies.where(workflow_id: workflow_instance.id).destroy_all
                process_instance.steps.destroy_all
                process_instance.destroy!
                @process_stats[:removed] += 1
              else
                Rails.logger.info("Process instance #{process_instance.id} has been started. Therefore, it cannot be removed in this rollout")
              end
            end
          end
        end

        def rollout_upgrades(workflow_instance)
          @workflow.selected_processes.where(state: 'upgraded').each do |sp|
            workflow_instance.processes.where(definition_id: sp.previous_version&.process_id, position: sp.previous_version&.position).each do |process_instance|
              if process_instance.unstarted?
                workflow_instance = process_instance.workflow
                # destroy any existing dependencies, will create new ones
                process_instance.workable_dependencies.where(workflow_id: workflow_instance.id).destroy_all
                process_instance.prerequisite_dependencies.where(workflow_id: workflow_instance.id).destroy_all
                process_instance.steps.destroy_all
                process_instance.destroy!

                new_process_instance = ::Workflow::Instance::Process::Create.run(sp.process, @workflow, workflow_instance)
                sp.process.workable_dependencies.where(workflow_id: @workflow.id).each do |dependency_definition|
                  create_dependency_later(dependency_definition, workflow_instance, new_process_instance)
                end
                sp.process.prerequisite_dependencies.where(workflow_id: @workflow.id).each do |prereq_definition|
                  create_prereq_dependency_later(prereq_definition, workflow_instance, new_process_instance)
                end
                if sp.process.workable_dependencies.where(workflow_id: @workflow.id).empty?
                  new_process_instance.prerequisites_met!
                end
                @process_stats[:upgraded] += 1
              else
                Rails.logger.info("Process instance #{process_instance.id} has been started. Therefore, it cannot be replaced/upgraded in this rollout")
              end
            end
          end
        end

        def rollout_repositions(workflow_instance)
          @workflow.selected_processes.where(state: "repositioned").each do |sp|
            workflow_instance.processes.where(definition_id: sp.previous_version&.process_id, position: sp.previous_version&.position).each do |process_instance|
              process_instance.position = sp.position
              process_instance.save!
              @process_stats[:repositioned] += 1
            end
          end
        end

        def rollout_dependencies
          @dependency_creators.each do |creator|
            creator.run
          end
        end

        def create_dependency_later(dependency_definition, workflow_instance, new_process_instance)
          if @dependency_creates[dependency_definition.id].nil?
            @dependency_creates[dependency_definition.id] = true
            @dependency_creators << ::Workflow::Instance::Dependency::Create.new(
              dependency_definition,
              workflow_instance,
              new_process_instance
            )
          end
        end

        def create_prereq_dependency_later(dependency_definition, workflow_instance, new_process_instance)
          if @dependency_creates[dependency_definition.id].nil?
            @dependency_creates[dependency_definition.id] = true
            @dependency_creators << ::Workflow::Instance::Dependency::Create.new(
              dependency_definition,
              workflow_instance,
              nil,
              new_process_instance
            )
          end
        end

        def finish_publish_stats
          if @process_stats[:error_raised]
            @workflow.needs_support = true
          else
            @workflow.published_at = DateTime.now
            @workflow.rollout_completed_at = DateTime.now
          end
          @workflow.save!

          Rails.logger.info("Finished rollout of workflow definition id #{@workflow.id}: #{@process_stats.inspect}")
        end
      end

      class PublishError < StandardError
      end
    end
  end
end
