module Workflow
  class Instance::Step
    class SelectDecisionOption < BaseService
      def initialize(step, person, decision_option)
        @step = step
        @person = person
        @decision_option = decision_option
      end

      def run
        assignment = @step.assignments.find_or_create_by!(assignee: @person)
        assignment.selected_option = @decision_option
        assignment.save!
      end
    end
  end
end
