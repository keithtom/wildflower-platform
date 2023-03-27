module Workflow
  class Instance::Step
    class Complete < BaseService
      # track startability of new steps as a metric, e.g. what did we unlock and as of when
      # that way we can see what's waiting in someone's court.
      # particularly for non-workers

      # after we complete, we need to see what's unlocked.
      # that's done later since state is changed..
      def initialize(step)
        @step = step
      end

      def run
        process = @step.process

        @step.completed = true
        @step.completed_at = DateTime.now
        @step.save!

        if process.completed_steps_count == process.steps.count
          process.completed_at = DateTime.now
          process.save!

          # check if all the processes in this phase are complete, and update current phase if so
          workflow = process.workflow
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

        if process.completed_steps_count == 1
          process.started_at = DateTime.now
          process.save!
        end
      end
    end
  end
end
