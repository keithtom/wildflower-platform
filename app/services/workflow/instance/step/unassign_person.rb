module Workflow
  class Instance::Step
    class UnassignPerson < BaseService
      def initialize(step, person)
        @step = step
        @person = person
      end

      def run
        @step.assignments.where(assignee: @person).destroy_all
      end
    end
  end
end
