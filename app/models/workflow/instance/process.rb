module Workflow
  class Instance::Process < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    belongs_to :definition, class_name: 'Workflow::Definition::Process', optional: true # for manual steps
    belongs_to :workflow

    has_many :steps, class_name: 'Workflow::Instance::Step'

    acts_as_taggable_on :categories
    enum effort: { small: 0, medium: 1, large: 2 }
    enum completion_status: { unstarted: 0, to_do: 1, in_progress: 2, done: 3 }

    scope :by_position, -> { order("workflow_instance_processes.position ASC") }


    def title
      super || self.definition.title
    end

    def description
      super || self.definition.description
    end

    def effort
      super || self.definition.effort
    end

    def workflow_url
      self.workflow.url
    end

    def position
      super || self.definition.position
    end

    def phase
      self.definition.phase
    end

    def assigned_and_incomplete?
      steps.where.not(assignee_id: nil).where(completed: false).length > 0
    end
  end
end
