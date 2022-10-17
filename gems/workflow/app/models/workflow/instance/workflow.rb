module Workflow
  class Instance::Workflow < ApplicationRecord
    has_many :processes
    belongs_to :definition, :class_name => 'Workflow::Definition::Workflow', foreign_key: 'workflow_definition_workflow_id'

    def name
      self.definition.name
    end

    def description
      self.definition.description
    end
  end
end
# definition, version, it contains the state of completed steps.
# so you know all the processes (they have state? cached?)
# so has all the steps
  # - assignee
  # - started_at
  # - completed_at
  # - role
  # - see commands...
  # - has manual steps
  # - also has a user id, every user has their own instance of the definition with state
    # - so there's a external_data_state
    # - ask maggie: users can never change the dependencies? just add new ones for manual
    # -
