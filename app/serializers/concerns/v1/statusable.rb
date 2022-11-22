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

    def completed_steps_count(process)
      process.steps.where(completed: true).count
    end

    def total_steps_count(process)
      step_count = process.steps.count
    end

    private

    def completion_status(process)
      case completed_steps_count(process)
      when 0
        return UNSTARTED
      when total_steps_count(process)
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
