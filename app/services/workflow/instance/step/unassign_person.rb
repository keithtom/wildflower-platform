module Workflow
  class Instance::Step
    class UnassignPerson < BaseService
      def initialize(step)
        @step = step
      end

      def run
        @step.assignee_id = nil
        @step.save!
      end
    end
  end
end
