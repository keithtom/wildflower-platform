module Workflow
  class Instance::Step < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    belongs_to :definition, class_name: 'Workflow::Definition::Step', optional: true
    belongs_to :process, class_name: 'Workflow::Instance::Process', counter_cache: true
    has_many :documents, as: :documentable
    belongs_to :selected_option, class_name: 'Workflow::DecisionOption', optional: true

    before_create :set_position
    after_save :update_completed_counter_cache
    after_destroy :update_completed_counter_cache

    DEFAULT_INCREMENT = 1000

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
      super || self.definition.try(:documents)
    end

    def position
      super || self.definition.try(:position)
    end

    def is_manual?
      definition.nil?
    end

    private

    def update_completed_counter_cache
      self.process.completed_steps_count = Workflow::Instance::Step.where(completed: true, process_id: process.id).count
      self.process.save
    end

    def set_position
      if self.position.nil?
        self.position = self.process.steps.order(:position).last.try(:position).to_i + DEFAULT_INCREMENT
      end
    end
  end
end
