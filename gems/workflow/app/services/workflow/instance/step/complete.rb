module Workflow
  class Instance::Step
    class Complete
      # track startability of new steps as a metric, e.g. what did we unlock and as of when
      # that way we can see what's waiting in someone's court.
      # particularly for non-workers

      # after we complete, we need to see what's unlocked.
      # that's done later since state is changed..
      def initialize(step)
        @step = step
      end

      def run
        @step.completed =true
        @step.completed_at =  DateTime.now
        @step.save!
      end
    end
  end
end
