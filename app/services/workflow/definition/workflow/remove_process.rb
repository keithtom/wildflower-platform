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
          create_association
        end
      
        def validate_workflow_state
          if @workflow.published?
            raise StandardError.new('Cannot remove processes from a published workflow. Please create a new version to continue.')
          end
        end
      
        def create_association
          selected_process = Workflow::Definition::SelectedProcess.where(workflow_id: @workflow.id, process_id: @process.id).last
          selected_process.destroy!
        end
      end
    end
  end
end
