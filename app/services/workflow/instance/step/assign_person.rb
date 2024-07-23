module Workflow
  class Instance::Step
    class AssignPerson < BaseService
      def initialize(step, person)
        @step = step
        @person = person
        @process = @step.process
      end

      def run
        validate_step_and_person
        assign_person
        update_process_completion_status
      end

      private

      def validate_step_and_person
        teams = @person.schools
        teams += [@person.ssj_team] if @person.ssj_team

        teams.each do |team|
          team.workflow_id == @process.workflow_id
          return true
        end
        raise AssignPersonError.new("Person email #{@person.email} cannot be assigned to this step because not part of the team/school")
      end

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
    class AssignPersonError < StandardError
    end
  end
end
