module Workflow
  module Definition
    class Step
      class PropogateChange
        VALID_ATTR_CHANGES = [
          :title, :description, :position, :completion_type, :min_worktime, :max_worktime, :decision_question, 
          decision_options_attributes: [:id, :description], 
          documents_attributes: [:id, :title, :link]
        ]

        def initialize(step_definition, param_changes)
          @step_definition = step_definition
          @param_changes = param_changes.to_hash
        end
      
        def run
          validate_param_changes
          # validate that the param changes are only the ones we allow
          # grab all the step_instances
          # see what the 
          # maybe update from the param changes?
        end
      
        def validate_param_changes
          action_on_unpermitted_parameters = ActionController::Parameters.action_on_unpermitted_parameters
          ActionController::Parameters.action_on_unpermitted_parameters = :raise

          begin
            ActionController::Parameters.new(@param_changes).permit(VALID_ATTR_CHANGES)
          rescue ActionController::UnpermittedParameters 
            raise StandardError.new("Attribute(s) cannot be an instantaneously changed")

            ActionController::Parameters.action_on_unpermitted_parameters = action_on_unpermitted_parameters
          end

          ActionController::Parameters.action_on_unpermitted_parameters = action_on_unpermitted_parameters
        end
      end
    end
  end
end
