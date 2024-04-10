module Workflow
  module Definition
    class Process
      class NewVersion < BaseService
        def initialize(workflow, process)
          @workflow = workflow
          @process = process
          @new_version = nil
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
          if @process.version.nil?
            raise Error.new("process must have a version")
          end
         
          if @workflow.published?
            raise Error.new("workflow cannot be published")
          end
        end

        def create_new_version
          @new_version = @process.dup
          @new_version.previous_version_id = @process.id
          @new_version.version = "v#{@process.version[1..-1].to_i + 1}"
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
              new_document = Document.create!(attributes)
            end
          
            step.decision_options.each do |decision_option|
              # decision options have external identifier, cannot use dup to clone
              attributes = decision_option.attributes.with_indifferent_access.slice(:description)
              attributes.merge!(decision_id: new_step.id)
              new_decision_option = ::Workflow::DecisionOption.create!(attributes)
            end
          end
        end
      
        # dependencies were already cloned when workflow definition was cloned. Update the process id here.
        def update_dependencies
          @process.workable_dependencies.each do |dependency|
            dependency.workable = @new_version
            dependency.save!
          end
        end
      
        def update_selected_process
          selected_process = ::Workflow::Definition::SelectedProcess.find_by!(workflow_id: @workflow.id, process_id: @process.id)
          selected_process.process_id = @new_version.id
          selected_process.upgrade!
          selected_process.save!
        end
      end
    end
  end
end
