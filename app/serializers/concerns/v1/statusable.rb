module V1::Statusable
  extend ActiveSupport::Concern

  UNSTARTED = "unstarted"
  TO_DO = "to do"
  IN_PROGRESS = "in progress"
  DONE = "done"
  UP_NEXT = "up next"

  STATUS = [DONE, IN_PROGRESS, TO_DO, UP_NEXT]

  class_methods do
    def process_status(process)
      case process.completion_status
      when "unstarted"
        return prerequisites_completed?(process) ? TO_DO : UP_NEXT
      when "in_progress"
        if process.assigned_and_incomplete?
          return IN_PROGRESS
        else
          return TO_DO
        end
      else
        return DONE
      end
    end

    private

    def prerequisites_completed?(process)
      completed = true
      Workflow::Instance::Process::FindPrerequisites.run(process).each do |prerequisite|
        unless prerequisite.done?
          completed = false
        end
      end

      return completed
    end
  end
end
