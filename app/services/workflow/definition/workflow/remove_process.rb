module Workflow
  module Definition
    class Workflow
      # Remove a process to workflow
      class RemoveProcess < BaseService
        def initialize(workflow, process)
          @workflow = workflow
          @process = process
          @selected_process = ::Workflow::Definition::SelectedProcess.find_by(workflow_id: @workflow.id, process_id: @process.id)
        end
      
        def run
          validate_workflow_state
          validate_dependency_of_others
          if validate_selected_process_state
            destroy_association
          end
        end
      
        private

        def validate_workflow_state
          if @workflow.published?
            raise RemoveProcessError.new('cannot remove processes from a published workflow. Please create a new version to continue.')
          end
        end
      
        def validate_dependency_of_others
          unless ::Workflow::Definition::Dependency.where(workflow_id: @workflow.id, prerequisite_workable_id: @process.id, prerequisite_workable_type: @process.class.to_s).empty?
            raise RemoveProcessError.new('cannot remove process that is a prerequisite of other processes')
          end
        end
      
        def validate_selected_process_state
          !@selected_process.removed?
        end
      
        def destroy_association
          if @selected_process.added?
            process = @selected_process.process
            unless process.published? || process.instances.count > 0
              # this process was created for the rollout originally. Can be entirely removed now.
              process.destroy!
            end
            @selected_process.destroy!
          elsif @selected_process.replicated?
            @selected_process.remove!
          elsif @selected_process.repositioned?
            @selected_process.remove!
          elsif @selected_process.upgraded?
            @selected_process.revert!
            @selected_process.remove!
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
