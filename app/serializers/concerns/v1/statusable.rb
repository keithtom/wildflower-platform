module V1::Statusable
  extend ActiveSupport::Concern

  UNSTARTED = "unstarted"
  TO_DO = "to do"
  IN_PROGRESS = "in progress"
  DONE = "done"
  UP_NEXT = "up next"

  COMPLETION_STATUS = [TO_DO, IN_PROGRESS, DONE]
  STATUS = [TO_DO, UP_NEXT, DONE]

  class_methods do
    def status(process)
      case completion_status(process)
      when UNSTARTED
        return prerequisites_completed?(process) ? TO_DO : UP_NEXT
      when IN_PROGRESS
        return TO_DO
      else
        return DONE
      end
    end

    private

    def completion_status(process)
      case process.completed_steps_count
      when 0
        return UNSTARTED
      when process.steps_count
        return DONE
      else
        return IN_PROGRESS
      end
    end

    def prerequisites_completed?(process)
      completed = true
      process.prerequisites.each do |prerequisite|
        if completion_status(prerequisite) != DONE
          completed = false
        end
      end

      return completed
    end
  end
end
