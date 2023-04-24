module Workflow
  class Instance::Process
    class Complete < BaseService
      # track startability of new processs as a metric, e.g. what did we unlock and as of when
      # that way we can see what's waiting in someone's court.
      # particularly for non-workers

      # after we complete, we need to see what's unlocked.
      # that's done later since state is changed..
      def initialize(process)
        @process = process
      end

      def run
        # @process.completed = true # do processes have these fields?  separate this to another table?
        # @process.completed_at = DateTime.now # this is on the step.
        @process.status = V1::Statusable::DONE
    
        @process.save!

        check_postrequisites_startable
        # maybe send notificaitons like emails

        # Maybe update a phase counter of milestones completed.
        # if process.completed_processs_count == 0
        #   process.completed_at = DateTime.now
        # end

        # if process.completed_processs_count == 1
        #   process.started_at = DateTime.now
        # end


      end

      private

      def check_postrequisites_startable
        Workflow::Instance::Process::FindPostrequisites.run(@process).each do |postrequisite|
          if Workflow::Instance::Process::Startable.run(postrequisite)
            postrequisite.status = V1::Statusable::TO_DO
            postrequisite.save!
          end
        end
      end
    end
  end
end
