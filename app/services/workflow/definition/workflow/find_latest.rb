module Workflow
  module Definition
    class Workflow
      # find the latest workflow definition that's ready for publishing
      # also will need to take params for charter or national default.
      class FindLatest < BaseService
        def run
          # just a stub for now
          Workflow::Definition::Workflow.order(created_at: :desc).first # where(published: true)
        end
      end
    end
  end
end
