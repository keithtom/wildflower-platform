module Workflow
  module Definition
    class Workflow
      # Remove a process to workflow
      class RemoveProcess < BaseService
        def initialize(workflow, process)
          @workflow = workflow
          @process = process
        end
      
        def run
          validate_workflow_state
          destroy_association
        end
      
        def validate_workflow_state
          if @workflow.published?
            raise StandardError.new('Cannot remove processes from a published workflow. Please create a new version to continue.')
          end
        end
      
        def destroy_association
          selected_process = Workflow::Definition::SelectedProcess.find(workflow_id: @workflow.id, process_id: @process.id)
          if selected_process.added?
            selected_process.destroy!
          elsif selected_process.replicated?
            selected_process.remove!
          elsif selected_process.upgraded?
            selected_process.revert!
            selected_process.remove!
          else
            raise RemoveProcessError.new("selected process is in an invalid state to be removed")
          end
        end
      end
    
      class RemoveProcessError < StandardError
      end
    end
  end
end
