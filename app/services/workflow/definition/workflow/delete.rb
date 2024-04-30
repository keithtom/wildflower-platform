module Workflow
  module Definition
    class Workflow
      # Delete workflow attributes
      class Delete
        # never allow deletion (maybe if there’s no instances that reference it?), maybe hiding.
      
        def initialize(workflow)
          @workflow = workflow
        end
      
        def run
          validate
          destroy_selected_processes
          destroy_dependencies
        end
      
        def validate
          if @workflow.published?
            raise DeleteError("Cannot delete a workflow that is published")
          end
        
          if @workflow.insances.count > 0
            raise DeleteError("Cannot delete a workflow that has instasnces")
          end
        end
      
        def destroy_selected_processes
        end
      
        def destroy_dependencies
        end
      end
    
      class DeleteError < StandardError
      end
    end
  end
end
