module Workflow
  class Instance::Step < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    belongs_to :definition, class_name: 'Workflow::Definition::Step', optional: true # for manual steps.
    belongs_to :process, counter_cache: true

    has_many :assignments, class_name: 'Workflow::Instance::StepAssignment', foreign_key: 'step_id'
    has_many :assignees, through: :step_assignments, source: :assignee
    
    has_many :documents, as: :documentable
    
    before_create :set_position

    scope :by_position, -> { order("workflow_instance_steps.position ASC") }
    scope :complete, -> { where(completed: true) }
    scope :incomplete, -> { where(completed: [false, nil]) }
    scope :assigned, -> { where(assigned: true) }
    scope :unassigned, -> { where(assigned: [false, nil]) }
    
    def title
      super || self.definition.try(:title)
    end

    def description
      self.definition.try(:description)
    end

    def kind
      super || self.definition.try(:kind)
    end

    def documents
      super.empty? ? self.definition.try(:documents) : super
    end

    def position
      super || self.definition.try(:position)
    end

    def completion_type
      super || self.definition.try(:completion_type)
    end

    def decision?
      (self.kind || self.definition.try(:kind)) == Workflow::Definition::Step::DECISION
    end

    def is_manual?
      definition.nil?
    end

    def individual?
      completion_type == Workflow::Definition::Step::EACH_PERSON
    end

    def collaborative?
      completion_type == Workflow::Definition::Step::ONE_PER_GROUP
    end

    private

    def set_position
      if self.position.nil?
        self.position = self.process.steps.order(:position).last.try(:position).to_i + ::Workflow::Definition::Step::DEFAULT_INCREMENT
      end
    end
  end
end
