module Workflow
  class Instance::Step
    class Uncomplete < BaseService
      def initialize(step, person)
        @step = step
        @process = @step.process
        @person = person
      end

      def run
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
        # raise error if the process was completed, we won't undo in this case
        raise Error, "Process was completed" if @process.completed?
        
        assignment = @step.assignments.for_person_id(@person.id).update(completed_at: nil)

        if @step.assignments.complete.count == 0
          @step.completed = false
          @step.save!
        end
      end    
      
      def check_relock_step_dependencies!
      end

      def update_process_completed_counter_cache
      end

      def update_process_completion_status
      end

      def unstart_process
      end
    end
  end
end
