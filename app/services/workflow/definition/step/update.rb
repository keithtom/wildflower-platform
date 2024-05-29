# frozen_string_literal: true

module Workflow
  module Definition
    class Step
      class Update < BaseService
        def initialize(step, step_params)
          @step = step
          @step_params = step_params.to_hash.with_indifferent_access
        end

        def run
          validate_position
          update_step
        end

        private

        def validate_position
          if (position = @step_params[:position])
            if (position.to_i.to_s != position.to_s) || (position.to_i < 1)
              raise UpdateError, 'position must be an integer greater than 0'
            end
          end
        end

        def update_step
          @step.update!(@step_params)
        end
      end
      class UpdateError < StandardError
      end
    end
  end
end
