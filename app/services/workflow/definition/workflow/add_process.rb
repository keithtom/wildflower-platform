module Workflow
  module Definition
    class Workflow
      # Add a process to workflow
      class AddProcess < BaseService
        def initialize(workflow, process)
          @workflow = workflow
          @process = process
        end
      
        def run
          validate_workflow_state
          create_association
        end
      
        private

        def validate_workflow_state
          if @workflow.published?
            raise AddProcessError.new('Cannot add processes to a published workflow. Please create a new version to continue.')
          end
        end
      
        def create_association
          sp = ::Workflow::Definition::SelectedProcess.create!(workflow_id: @workflow.id, process_id: @process.id)
          sp.add!
          return sp
        end
      end
      class AddProcessError < StandardError
      end
    end
  end
end
