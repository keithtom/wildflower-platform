module V1::Statusable
  extend ActiveSupport::Concern

  IN_PROGRESS = "in progress" # In the UI, usually means assigned but not completed.  This helps the users focus on which tasks to work on of the available ones.
  TO_DO = "to do" # In the UI, this usually means the work is ready and available to be worked on.
  UP_NEXT = "up next" # In the UI, this means the work isn't ready to be worked on yet, usually becomes of an unmet prerequisite.
  DONE = "done" # In the UI, this means the work is completed.
  
  STATUS = [IN_PROGRESS, TO_DO, UP_NEXT, DONE]
  
  class_methods do
    def process_status(process)
      case 
      when process.unstarted?
        process.prerequisites_met? ? TO_DO : UP_NEXT
      when process.started?
        process.assigned_and_incomplete? ? IN_PROGRESS : TO_DO
      when process.finished?
        DONE
      else
        raise "Unknown status for process #{process.id} #{process.completion_status} #{process.dependency_cache}"
      end
    end
  end
end
  