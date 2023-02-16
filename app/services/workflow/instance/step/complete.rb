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

        if process.completed_steps_count == 0
          process.completed_at = DateTime.now
        end

        if process.completed_steps_count == 1
          process.started_at = DateTime.now
        end
      end
    end
  end
end
