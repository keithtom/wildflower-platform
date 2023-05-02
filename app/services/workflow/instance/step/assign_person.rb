module Workflow
  class Instance::Step
    class AssignPerson < BaseService
      def initialize(step, person)
        @step = step
        @person = person
        @process = @step.process
      end

      def run
        assign_person
        update_process_completion_status
      end

      private

      def assign_person
        # NOTE: if the step worktype was "only 1 assigner", we'd unassign first.
        @step.assignments.find_or_create_by!(assignee: @person)
        @step.assigned = true
        @step.save!
      end

      def update_process_completion_status
        @process.started!
      end
    end
  end
end
