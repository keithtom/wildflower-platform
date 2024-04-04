module Workflow
  module Definition
    class Workflow
      class NewVersion < BaseService
        def initialize(workflow)
          @workflow = workflow
          @new_version = nil
        end
      
        def run
          create_new_version
          clone_selected_processes
          return @new_version
        end
      
        private

        def create_new_version
          @new_version = @workflow.dup
          @new_version.previous_version_id = @workflow.id
          @new_version.version = "v#{@workflow.version[1..-1].to_i + 1}"
          @new_version.save!
        end
      
        # TODO: pusb this to a background worker?
        def clone_selected_processes
          @workflow.selected_processes.each do |sp|
            new_sp = sp.dup
            new_sp.workflow_id = @new_version.id
            new_sp.previous_version_id = sp.id
            new_sp.save!
          end
        end
      end
    end
  end
end