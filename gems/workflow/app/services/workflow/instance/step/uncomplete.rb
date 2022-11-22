module Workflow
  class Instance::Step
    class Uncomplete < Workflow::Service
      def initialize(step)
        @step = step
      end

      def run
        @step.completed = false
        @step.completed_at = nil
        @step.save!
      end
    end
  end
end