module Workflow
  class Instance::Process
    class AddManualStep < Workflow::Service
      def initialize(process, step_params)
        @process = process
        @step_params = step_params
      end

      def run
        last_step = @process.steps.last
        last_step_position = last_step.nil? ? 0 : last_step.position + 100
        @step_params[:position] = last_step_position + 100
        step = @process.steps.create!(@step_params)
        return step
      end
    end
  end
end
