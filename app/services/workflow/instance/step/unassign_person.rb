module Workflow
  class Instance::Step
    class UnassignPerson < BaseService
      def initialize(step, person)
        @step = step
        @person = person
      end

      # make sure it works even if person isn't assigned, should still succed
      def run
        @step.step_assignments.where(assignee: @person).destroy_all
      end
    end
  end
end
