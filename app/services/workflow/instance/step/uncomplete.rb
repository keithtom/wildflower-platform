module Workflow
  class Instance::Step
    class Uncomplete < BaseService
      def initialize(step, person)
        @step = step
        @process = @step.process
        @person = person
      end

      def run
        # raise error if the process was completed, we won't undo in this case
        raise Error, "Process was completed" if @process.completed?

        # return if already uncompleted by this specific person
        uncomplete_step!

        # undo dependency if no others have completed.
        check_relock_step_dependencies!

        update_process_completed_counter_cache
        update_process_completion_status
        unstart_process

        # unnotify people?
      end

      private

      def uncomplete_step!        
        assignment = @step.assignments.for_person_id(@person.id).update(completed_at: nil)

        if @step.assignments.complete.count == 0
          @step.completed = false
          @step.save!
        end
      end    
      
      def check_relock_step_dependencies!
        # no-op for now
      end

      def update_process_completed_counter_cache
        @process.completed_steps_count = @process.steps.complete.count
        @process.save!
      end

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

      def unstart_process
      end
    end
  end
end
