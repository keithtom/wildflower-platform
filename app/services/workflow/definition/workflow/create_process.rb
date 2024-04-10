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
            raise CreateProcessError.new('Cannot add processes to a published workflow. Please create a new version to continue.')
          end
        end
      
        def create_process
          @process = ::Workflow::Definition::Process.create!(@process_params)
          sp = ::Workflow::Definition::SelectedProcess.create!(workflow_id: @workflow.id, process_id: @process.id)
          sp.add!
        end
      end
    
      class CreateProcessError < StandardError
      end
    end
  end
end
