module Workflow
  class Instance::Process
    class AssignPerson < BaseService
      def initialize(process, person)
        @process = process
        @person = person
      end

      def run
        @process.assignee_id = @person.id
        @process.save!
      end
    end
  end
end
