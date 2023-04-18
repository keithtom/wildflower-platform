module Workflow
  class Instance::Process
    class Start < BaseService
      def initialize(process)
        @process = process
      end

      def run
      end

      private
    end
  end
end