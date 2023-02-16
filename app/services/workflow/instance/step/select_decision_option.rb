module Workflow
  class Instance::Step
    class SelectDecisionOption < BaseService
      def initialize(step, decision_option)
        @step = step
        @decision_option = decision_option
      end

      def run
        @step.selected_option = @decision_option
        @step.save!
      end
    end
  end
end
