module Workflow
  class Instance::Step
    class UnassignPerson < BaseService
      def initialize(step, person)
        @step = step
        @person = person
        @process = @step.process
      end

      def run
        unassign_person
        update_process_completion_status
      end

      private

      def unassign_person
        @step.assignments.where(assignee: @person).destroy_all

        if @step.assignments.any?
          @step.assigned = false
          @step.save!
        end
      end

      # might only ever be unstarted if no other assignments
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
