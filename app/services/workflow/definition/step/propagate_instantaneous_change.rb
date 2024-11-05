module Workflow
  module Definition
    class Step
      class PropagateInstantaneousChange < BaseService
        VALID_ATTR_CHANGES = [
          :title, :title_es, :description, :description_es, :position, :completion_type, :min_worktime, :max_worktime,
          :decision_question, :decision_question_es, { documents_attributes: %i[id title title_es link],
                                                       decision_options_attributes: %i[id description description_es] }
        ]

        def initialize(step_definition, param_changes)
          @step_definition = step_definition
          @param_changes = param_changes.to_hash.with_indifferent_access
        end

        def run
          validate_param_changes
          update_definition
          scrub_param_changes
          update_instances
        end

        private

        def validate_param_changes
          action_on_unpermitted_parameters = ActionController::Parameters.action_on_unpermitted_parameters
          ActionController::Parameters.action_on_unpermitted_parameters = :raise

          begin
            ActionController::Parameters.new(@param_changes).permit(VALID_ATTR_CHANGES)
          rescue ActionController::UnpermittedParameters => e
            ActionController::Parameters.action_on_unpermitted_parameters = action_on_unpermitted_parameters
            raise StandardError, "Attribute(s) cannot be an instantaneously changed: #{e.params.join(', ')}"
          end

          ActionController::Parameters.action_on_unpermitted_parameters = action_on_unpermitted_parameters
        end

        def update_definition
          @step_definition.update!(@param_changes)
        end

        def scrub_param_changes
          # these attributes are not copied over to the instance
          @param_changes.delete(:documents_attributes)
          @param_changes.delete(:decision_options_attributes)
        end

        def update_instances
          @step_definition.instances.update_all(@param_changes) unless @param_changes.empty?
        end
      end
    end
  end
end
