module Workflow
  class Instance::Step
    class UnassignPerson < BaseService
      def initialize(step, assignee, person)
        @step = step
        @assignee = assignee
        @person = person
        @process = @step.process
      end

      def run
        validate_person_can_unassign
        unassign_person
        update_process_completion_status
      end

      private

      # check if person and assignee are part of the same team/school
      def validate_person_can_unassign
        workflow_id = @step.process.workflow_id
        group = SSJ::Team.find_by(workflow_id:) || School.find_by(workflow_id:)
        unassignable = false

        group.people.each do |person|
          unassignable = true if person.id == @person.id
        end

        unless unassignable
          raise UnassignPersonError, "#{@person.email} cannot unassign step #{@step.external_identifier}"
        end
      end

      def unassign_person
        @step.assignments.where(assignee: @assignee).destroy_all

        if @step.assignments.any?
          @step.assigned = false
          @step.save!
        end
      end

      # might only ever be unstarted if no other assignments
      def update_process_completion_status
        @process.unstarted! unless @process.assigned_and_incomplete?
      end
    end

    class UnassignPersonError < StandardError
    end
  end
end
