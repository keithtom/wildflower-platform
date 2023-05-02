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

      # should really only ever be start here...
      def update_process_completion_status
        case @process.completed_steps_count
        when 0
          if @process.assigned_and_incomplete?
            @process.started!
          else
            @process.unstarted!
          end
        when @process.steps_count
          @process.finished!
        else
          @process.started!
        end  
      end
    end
  end
end
