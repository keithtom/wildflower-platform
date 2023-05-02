module Workflow
  class Definition::Step < ApplicationRecord
    belongs_to :process
    has_many :documents, as: :documentable
    has_many :instances, class_name: 'Workflow::Instance::Step', foreign_key: 'definition_id'
    has_many :decision_options, class_name: 'Workflow::DecisionOption', foreign_key: 'decision_id'

    before_create :set_position

    DEFAULT_INCREMENT = 1000

    ACTION_KINDS = [DECISION = "decision", DEFAULT = "default"]

    COMPLETION_TYPES = [EACH_PERSON = 'each_person', ONE_PER_GROUP = 'one_per_group'].freeze

    scope :by_position, -> { order("workflow_definition_steps.position ASC") }
    
    validates :kind, presence: true, inclusion: { in: Workflow::Definition::Step::ACTION_KINDS }
    validates :completion_type, presence: true, inclusion: { in: Workflow::Definition::Step::COMPLETION_TYPES }

    private

    def set_position
      if position.nil?
        self.position = self.process.steps.order(:position).last.try(:position).to_i + DEFAULT_INCREMENT
      end
    end
  end
end

