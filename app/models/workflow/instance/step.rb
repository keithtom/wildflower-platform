module Workflow
  class Instance::Step < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    audited

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

    # currently it can be empty while it defers to definition
    # validates :kind, presence: true, inclusion: { in: Workflow::Definition::Step::ACTION_KINDS }
    # validates :completion_type, presence: true, inclusion: { in: Workflow::Definition::Step::COMPLETION_TYPES }
    
    def title
      super || self.definition.try(:title)
    end

    def description
      self.definition.try(:description)
    end

    def kind
      super || self.definition.try(:kind)
    end

    def position
      super || self.definition.try(:position)
    end

    def completion_type
      super || self.definition.try(:completion_type)
    end

    def documents
      super.empty? ? self.definition.try(:documents) : super
    end

    def decision?
      kind == Workflow::Definition::Step::DECISION
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

    def assigned_to?(person)
      assignments.where(assignee: person).exists?
    end

    def completed_by_me?(person)
      assignments.complete.where(assignee: person).exists?
    end

    def completed_by_anyone?
      assignments.complete.exists?
    end

    def completed_for?(person)
      case
      when individual?
        completed_by_me?(person)
      when collaborative?
        completed_by_anyone?
      else
        raise "Unknown completion type: #{step.completion_type}"
      end
    end

    private

    def set_position
      if self.position.nil?
        self.position = self.process.steps.order(:position).last.try(:position).to_i + ::Workflow::Definition::Step::DEFAULT_INCREMENT
      end
    end
  end
end
