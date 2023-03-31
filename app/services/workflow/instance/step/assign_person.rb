module Workflow
  class Instance::Step
    class AssignPerson < BaseService
      def initialize(step, person)
        @step = step
        @person = person
      end

      # TODO: spec this to allow multiple assignees, and do nothing if already assigned.
      def run
        # NOTE: if the step worktype was "only 1 assigner", we'd unassign first.
        # but here it is purely additive and idempotent (if already assigned do nothign.).
        @step.assignments.find_or_create_by!(assignee: @person)
      end
    end
  end
end
