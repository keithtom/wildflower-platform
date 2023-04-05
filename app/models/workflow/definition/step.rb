module Workflow
  class Definition::Step < ApplicationRecord
    belongs_to :process
    has_many :documents, as: :documentable
    has_many :instances, class_name: 'Workflow::Instance::Step', foreign_key: 'definition_id'
    has_many :decision_options, class_name: 'Workflow::DecisionOption', foreign_key: 'decision_id'

    before_create :set_position

    DEFAULT_INCREMENT = 1000
    DECISION = "Decision"
    DEFAULT = "default"

    private

    def set_position
      if position.nil?
        self.position = self.process.steps.order(:position).last.try(:position).to_i + DEFAULT_INCREMENT
      end
    end
  end
end

