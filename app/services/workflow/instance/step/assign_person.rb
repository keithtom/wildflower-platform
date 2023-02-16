module Workflow
  class Instance::Step
    class AssignPerson < BaseService
      def initialize(step, person)
        @step = step
        @person = person
      end

      def run
        @step.assignee_id = @person.id
        @step.save!
      end
    end
  end
end
