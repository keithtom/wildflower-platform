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
          clone_dependencies
          @new_version
        end

        private

        def create_new_version
          @new_version = @workflow.dup
          @new_version.previous_version_id = @workflow.id
          @new_version.version = "v#{@workflow.version[1..-1].to_i + 1}"
          @new_version.published_at = nil
          @new_version.rollout_started_at = nil
          @new_version.rollout_completed_at = nil
          @new_version.needs_support = false
          @new_version.save!
        end

        # TODO: pusb this to a background worker?
        def clone_selected_processes
          @workflow.selected_processes.where.not(state: 'removed').each do |sp|
            new_sp = sp.dup
            new_sp.workflow_id = @new_version.id
            new_sp.previous_version_id = sp.id
            new_sp.state = 'replicated'
            new_sp.save!
          end
        end

        def clone_dependencies
          @workflow.dependencies.each do |dependency|
            new_dependency = dependency.dup
            new_dependency.workflow_id = @new_version.id
            new_dependency.save!
          end
        end
      end
    end
  end
end
