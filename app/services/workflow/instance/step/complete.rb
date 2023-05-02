module Workflow
  class Instance::Step
    class Complete < BaseService
      def initialize(step, person)
        @step = step
        @process = @step.process
        @person = person
      end

      # TODO: service spec shoudl test idempotency
      def run
        # return if step already completed by this person.
        complete_step

        # TODO: dependency graphs won't change if already step.completed = true
        check_unlocked_step_postrequisites

        update_process_completed_counter_cache
        update_process_completion_status
        start_process
        complete_process

        notify_people # TODO: don't send notifications if learnign step was completed already by another ETL first.
      end

      private

      def complete_step
        # simplifying assumption: completed is true if at least 1 person completed it regardless of worktype = individual or collaborative
        # this is because milestone progress is based on any single person completing the steps.
        # The new requirements to have "learning" or individual steps be completed by each partner was done so that the system doesn't give the impression that only 1 partner has to complete learning tasks.
        @step.completed = true 
        @step.save!
        
        assignment = @step.assignments.find_or_create_by!(assignee: @person)
        assignment.completed_at ||= DateTime.now
        assignment.save!
      end

      def check_unlocked_step_postrequisites
        # check for any unlocked steps.
        # TODO: we aren't implementing any of these yet because Maggie hasn't needed it, but system is capable of it.
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

      def start_process
        # This is not so important yet, but technically it'd be started when the first step is assigned.
        if @process.completed_steps_count == 1
          @process.started_at = DateTime.now
          @process.save!
        end
      end

      def complete_process
        if @process.completed_steps_count == @process.steps_count
          Workflow::Instance::Process::Complete.run(@process)
        end
      end

      def notify_people
        # send emails to relevant people based on step.
      end
    end
  end
end
