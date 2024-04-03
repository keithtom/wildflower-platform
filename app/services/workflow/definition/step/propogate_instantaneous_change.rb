module Workflow
  module Definition
    class Step
      class PropogateInstantaneousChange < BaseService
        VALID_ATTR_CHANGES = [
          :title, :description, :position, :completion_type, :min_worktime, :max_worktime, :decision_question, 
        ]

        def initialize(step_definition, param_changes)
          @step_definition = step_definition
          @param_changes = param_changes.to_hash.with_indifferent_access
        end
      
        def run
          scrub_param_changes
          validate_param_changes
          update_instances
        end
      
        private 
        def scrub_param_changes
          # these attributes were not copied over to the instance
          @param_changes.delete(:documents_attributes)
          @param_changes.delete(:decision_option_attributes)
        end

        def validate_param_changes
          action_on_unpermitted_parameters = ActionController::Parameters.action_on_unpermitted_parameters
          ActionController::Parameters.action_on_unpermitted_parameters = :raise

          begin
            ActionController::Parameters.new(@param_changes).permit(VALID_ATTR_CHANGES)
          rescue ActionController::UnpermittedParameters => e
            raise StandardError.new("Attribute(s) cannot be an instantaneously changed: #{e.params.join(", ")}")

            ActionController::Parameters.action_on_unpermitted_parameters = action_on_unpermitted_parameters
          end

          ActionController::Parameters.action_on_unpermitted_parameters = action_on_unpermitted_parameters
        end
      
        def update_instances
          @step_definition.instances.update_all(@param_changes)
        end
      end
    end
  end
end
