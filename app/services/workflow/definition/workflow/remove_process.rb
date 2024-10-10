module Workflow
  module Definition
    class Workflow
      # Remove a process to workflow
      class RemoveProcess < BaseService
        def initialize(workflow, process)
          @workflow = workflow
          @process = process
          @selected_process = ::Workflow::Definition::SelectedProcess.find_by(workflow_id: @workflow.id,
                                                                              process_id: @process.id)
        end

        def run
          validate_workflow_state
          validate_dependency_of_others
          destroy_association if validate_selected_process_state
        end

        private

        def validate_workflow_state
          if @workflow.published?
            raise RemoveProcessError,
                  'cannot remove processes from a published workflow. Please create a new version to continue.'
          end
        end

        def validate_dependency_of_others
          unless ::Workflow::Definition::Dependency.where(workflow_id: @workflow.id,
                                                          prerequisite_workable_id: @process.id, prerequisite_workable_type: @process.class.to_s).empty?
            raise RemoveProcessError, 'cannot remove process that is a prerequisite of other processes'
          end
        end

        def validate_selected_process_state
          !@selected_process.removed?
        end

        def destroy_association
          if @selected_process.added? || @selected_process.initialized?
            process = @selected_process.process
            unless process.published? || process.instances.count > 0
              # this process was created for the rollout originally. Can be entirely removed now.
              process.destroy!
            end
            @selected_process.destroy!
          elsif @selected_process.replicated?
            # remove dependencies
            @selected_process.process.workable_dependencies.where(workflow_id: @selected_process.workflow_id).destroy_all
            @selected_process.process.prerequisite_dependencies.where(workflow_id: @selected_process.workflow_id).destroy_all

            @selected_process.remove!
          elsif @selected_process.repositioned?
            @selected_process.remove!
          elsif @selected_process.upgraded?
            ::Workflow::Definition::SelectedProcess::Revert.run(@selected_process)
            @selected_process.reload
            # once reverted to replicated state, call destroy_association to ensure removal of dependencies
            destroy_association
          else
            raise RemoveProcessError, 'selected process is in an invalid state to be removed'
          end
        end
      end

      class RemoveProcessError < StandardError
      end
    end
  end
end
