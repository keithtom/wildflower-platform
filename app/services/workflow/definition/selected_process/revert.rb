module Workflow
  module Definition
    class SelectedProcess
      class Revert < BaseService
        def initialize(selected_process)
          @selected_process = selected_process
          @new_process = @selected_process.process
          @original_process = @selected_process.previous_version&.process
        end
      
        def run
          validate_previous_version
          revert_dependencies
          revert_process
          revert_position
          @selected_process.revert!
        end
      
        private

        def validate_previous_version
          raise RevertError, 'no previous version to revert to' if @selected_process.previous_version.nil?
        end

        def revert_dependencies
          @new_process.workable_dependencies.where(workflow_id: @selected_process.workflow_id).each do |dep|
            dep.workable = @original_process
            dep.save!
          end
          @new_process.prerequisite_dependencies.where(workflow_id: @selected_process.workflow_id).each do |dep|
            dep.prerequisite_workable = @original_process
            dep.save!
          end
        end
        
        def revert_process
          @new_process.destroy! if @selected_process.upgraded? # if upgraded then it means this process was created just for this rollout/workflow
          @selected_process.process = @original_process
          @selected_process.save!
        end
        
        def revert_position
          @selected_process.position = @selected_process.previous_version&.position
          @selected_process.save!
        end
      end
      class RevertError < StandardError
      end
    end
  end
end
