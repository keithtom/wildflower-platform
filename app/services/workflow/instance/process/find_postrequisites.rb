module Workflow
  module Instance
    class Process
      class FindPostrequisites < BaseService
        # Ideally i shouldn't care if this is a step or a process, but the code right now works only for a process.
        def initialize(process)
          @process = process
        end

        def run
          dependency_ids = ::Workflow::Instance::Dependency.where(workflow_id: @process.workflow_id, workable_type: "Process", prerequisite_workable_type: "Process", prerequisite_workable_id: @process.id).pluck(:workable_id)
          # TODO: check for for step dependencies
          postrequisites = ::Workflow::Instance::Process.where(id: dependency_ids)
        end
      end
    end
  end
end