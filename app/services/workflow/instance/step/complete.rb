module Workflow
  class Instance::Step
    class Complete < BaseService
      # track startability of new steps as a metric, e.g. what did we unlock and as of when
      # that way we can see what's waiting in someone's court.
      # particularly for non-workers

      # after we complete, we need to see what's unlocked.
      # that's done later since state is changed..
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
            @process.in_progress!
          else
            @process.unstarted!
          end
        when @process.steps_count
          @process.done!
        else
          @process.in_progress!
        end  
      end

      def start_process
        # This is not so important yet, but technically it'd be started when the first step is assigned.
        if @process.completed_steps_count == 1
          @process.started_at = DateTime.now
          @process.save!
        end
      end

      # check if the that was the last step and complete the process
      # TODO: move this to a Process::Complete service
      def complete_process
        if @process.completed_steps_count == @process.steps_count
          @process.completed_at = DateTime.now
          @process.save!

          # check if all the processes in this phase are complete, and update current phase if so
          workflow = @process.workflow
          current_phase_complete = true
          workflow.processes.where.not(completion_status: 3).each do |p|
            if p.phase.first.name == workflow.current_phase
              current_phase_complete = false
            end
          end
          if current_phase_complete
            current_phase_index = Workflow::Definition::Process::PHASES.index(workflow.current_phase)
            workflow.current_phase = Workflow::Definition::Process::PHASES[current_phase_index + 1]
            workflow.save!
          end
        end
      end

      def notify_people
        # send emails to relevant people based on step.
      end
    end
  end
end
