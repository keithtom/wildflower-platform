module Workflow
  class Instance::Step
    class AssignPerson < BaseService
      def initialize(step, person)
        @step = step
        @person = person
      end

      def run
        # NOTE: if the step worktype was "only 1 assigner", we'd unassign first.
        @step.assignments.find_or_create_by!(assignee: @person)
        @step.assigned = true
        @step.save
      end
    end
  end
end
