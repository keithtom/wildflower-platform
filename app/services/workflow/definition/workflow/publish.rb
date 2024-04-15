module Workflow
  module Definition
    class Workflow
      class Publish < BaseService
        def initialize(workflow)
          @workflow = workflow

          @process_stats = {
            added: 0,
            removed: 0,
            upgraded: 0
          }
          @selected_processes = []
        end
      
        def run
          validate_workflow
          set_tracking_stats
          rollout_adds
          rollout_removes
          rollout_upgrades
          finish_publish_stats
          # create_dependency_instances
          # update_process_dependencies
          
          # TODO:
          # 1. check that process compltion_status is actually set correctly
          # 2. create dependency instances
          # 3. update process dependencies
        end
      
        private
        
        def validate_workflow
          # workflow should only be in draft mode
          # workflow should have selected_processes where the state is not replicated
        end

        def set_tracking_stats
          @workflow.rollout_started_at = DateTime.now
          @workflow.save!
          
          # todo: probably need more stats
        end
      
        def rollout_adds
          @workflow.selected_processes.where(state: "added").each do |sp|
            @workflow.instances.each do |workflow_instance|
              previous_process_by_position = workflow_instance.processes.order(position: :desc).where("position < ?", sp.position).first
              if previous_process_by_position.completion_status !== "finished"
                process_instance = Workflow::Instance::Process::Create.run(sp.process, workflow_instance)
                sp.process.workable_dependencies.where(workflow_id: @workflow.id).each do |dependency_definition|
                  Workflow::Instance::Dependency::Create.run(dependency_definition, workflow_instance, process_instance)
                end
              else
                Rails.logger.info("Previous process #{previous_process_by_position.id} has been started. Therefore, the new process definition #{sp.process_id} will not be added to this rollout")
              end
            end
          end
        end

        def rollout_removes
          @workflow.selected_processes.where(state: "removed").each do |sp|
            Workflow::Instance::Process.joins(:workflow).
              where(workflow: { definition_id: @workflow.id }).
              where(definition_id: sp.process_id).each do |process_instance|
              
              if process_instance.completion_status == "unstarted"
                process_instance.destroy!
                # TODO: delete its dependencies as well
              else
                Rails.logger.info("Process instance #{process_instance.id} has been started. Therefore, it cannot be removed in this rollout")
              end
            end
          end
        end
        
        def rollout_upgrades
          @workflow.selected_processes.where(state: "upgraded").each do |sp|
            Workflow::Instance::Process.joins(:workflow).
              where(workflow: { definition_id: @workflow.id }).
              where(definition_id: sp.process_id).each do |process_instance|
              
              if process_instance.completion_status == "unstarted"
                workflow_instance = process_instance.workflow
                process_instance.destroy!
                # TODO: delete its dependencies as well
                process_instance = Workflow::Instance::Process::Create.run(sp.process, workflow_instance)
                sp.process.workable_dependencies.where(workflow_id: @workflow.id).each do |dependency_definition|
                  Workflow::Instance::Dependency::Create.run(dependency_definition, workflow_instance, process_instance)
                end
              else
                Rails.logger.info("Process instance #{process_instance.id} has been started. Therefore, it cannot be replaced/upgraded in this rollout")
              end
            end
          end
        end
      
        def finish_publish_stats
          @workflow.published_at = DateTime.now
          @workflow.rollout_finished_at = DateTime.now
          @workflow.save
        end
      end
    end
  end
end
