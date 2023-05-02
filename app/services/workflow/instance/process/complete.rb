module Workflow
  class Instance::Process
    class Complete < BaseService
      def initialize(process)
        @process = process
      end

      def run
        # check if steps done?
        complete_process

        check_postrequisites_startable
        
        # Maybe update a phase counter of milestones completed.
        
        update_current_phase

        # upon completing a process we should update the dependencies
        
        notify_people
      end

      private

      def complete_process
        # @process.completed = true # do processes have these fields?  separate this to another table?
        @process.completed_at = Time.now
        @process.finished!
        @process.save!
      end

      def prerequisites_completed?(process)
        process.prerequisites.not_finished.empty?
      end
    
      def check_postrequisites_startable
        @process.postrequisites.each do |postrequisite|
          # for this postrequisite, check if all prerequisites are complete
          if postrequisite.prerequisites.not_finished.empty?
            postrequisite.dependencies_met!
          end
        end
      end

      def update_current_phase
        # check if all the processes in this phase are complete, and update current phase if so
        workflow = @process.workflow

        # if there are no processes tagged with the current phase and are not finished, then the phase is complete
        current_phase_complete = workflow.processes.not_finished.tagged_with(workflow.current_phase, on: :phase, any: true).empty?

        if current_phase_complete
          current_phase_index = SSJ::Phase::PHASES.index(workflow.current_phase)
          workflow.current_phase = SSJ::Phase::PHASES[current_phase_index + 1]
          workflow.save!
        end
      end

      def notify_people
      end
    end
  end
end
