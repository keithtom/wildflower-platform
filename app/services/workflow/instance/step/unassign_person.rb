module Workflow
  class Instance::Step
    class UnassignPerson < BaseService
      def initialize(step, person)
        @step = step
        @person = person
      end

      def run
        @step.assignments.where(assignee: @person).destroy_all

        if @step.assignments.any?
          @step.assigned = false
          @step.save
        end
      end
    end
  end
end
