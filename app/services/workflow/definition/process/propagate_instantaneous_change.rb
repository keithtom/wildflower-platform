module Workflow
  module Definition
    class Process
      class PropagateInstantaneousChange < BaseService
        VALID_ATTR_CHANGES = [
          :title, :description, :position, [:category_list => []]
        ]

        def initialize(process_definition, param_changes)
          @process_definition = process_definition
          @param_changes = param_changes.to_hash.with_indifferent_access
          @workflow_id = nil
          @category_list = nil
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
            raise StandardError.new("Attribute(s) cannot be an instantaneously changed: #{e.params.join(", ")}")
          end

          ActionController::Parameters.action_on_unpermitted_parameters = action_on_unpermitted_parameters
        end

        def update_definition
          @process_definition.update!(@param_changes)
        end

        def scrub_param_changes
          if selected_processes_attributes = @param_changes.delete(:selected_processes_attributes)
            if selected_processes_attributes.count > 1
              raise StandardError.new("Can only update position of process to one workflow")
            end

            selected_process = selected_processes_attributes.first
            @workflow_id = selected_process[:workflow_id]
          end

          @category_list = @param_changes.delete(:category_list)
        end

        def update_instances
          unless @param_changes.empty?
            @process_definition.instances.update_all(@param_changes)
          end

          # TODO: push this to a background worker?
          if @category_list
            @process_definition.instances.each do |instance|
              instance.category_list = @category_list
              instance.save!
            end
          end
        end
      end
    end
  end
end
