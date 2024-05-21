module Workflow
  module Definition
    class Process
      class NewVersion < BaseService
        def initialize(workflow, process)
          @workflow = workflow
          @process = process
          @new_version = nil
          @selected_process = ::Workflow::Definition::SelectedProcess.find_by!(workflow_id: @workflow.id, process_id: @process.id)
        end

        def run
          validate
          create_new_version
          clone_steps
          update_dependencies
          update_selected_process
          return @new_version
        end

        private

        def validate
          raise Error, 'process must have a version' if @process.version.nil?

          raise Error, 'workflow cannot be published' if @workflow.published?
        end

        def create_new_version
          @new_version = @process.dup
          @new_version.previous_version_id = @process.id
          @new_version.version = "v#{@process.version[1..-1].to_i + 1}"
          @new_version.published_at = nil 
          @new_version.phase_list = @process.phase_list
          @new_version.category_list = @process.category_list
          @new_version.save!
        end

        # TODO: push this to a background worker?
        def clone_steps
          @process.steps.each do |step|
            new_step = step.dup
            new_step.process_id = @new_version.id
            new_step.save!

            step.documents.each do |document|
              # documents have external identifier, cannot use dup to clone
              attributes = document.attributes.with_indifferent_access.slice(:documentable_type, :inheritance_type, :title, :link)
              attributes.merge!(documentable_id: new_step.id)
              Document.create!(attributes)
            end

            step.decision_options.each do |decision_option|
              # decision options have external identifier, cannot use dup to clone
              attributes = decision_option.attributes.with_indifferent_access.slice(:description)
              attributes.merge!(decision_id: new_step.id)
              ::Workflow::DecisionOption.create!(attributes)
            end
          end
        end

        # dependencies were already cloned when workflow definition was cloned. Update the process id here.
        def update_dependencies
          @process.workable_dependencies.where(workflow_id: @workflow.id).each do |dependency|
            dependency.workable = @new_version
            dependency.save!
          end
          @process.prerequisite_dependencies.where(workflow_id: @workflow.id).each do |prereq_dependency|
            prereq_dependency.prerequisite_workable = @new_version
            prereq_dependency.save!
          end
        end

        def update_selected_process
          @selected_process.process_id = @new_version.id
          @selected_process.upgrade!
          @selected_process.save!
        end
      end
    end
  end
end
