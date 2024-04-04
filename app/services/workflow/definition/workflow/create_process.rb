module Workflow
  module Definition
    class Workflow
      # Add a process to workflow
      class CreateProcess < BaseService
        def initialize(workflow, process_params)
          @workflow = workflow
          @process_params = process_params
          @process = nil
        end
      
        def run
          validate_workflow_state
          create_process
          return @process
        end
      
        def validate_workflow_state
          if @workflow.published?
            raise StandardError.new('Cannot add processes to a published workflow. Please create a new version to continue.')
          end
        end
      
        def create_process
          @process = ::Workflow::Definition::Process.create!(@process_params)
          ::Workflow::Definition::SelectedProcess.create!(workflow_id: @workflow.id, process_id: @process.id)
        end
      end
    end
  end
end
