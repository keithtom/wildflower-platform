module Workflow
  class Instance::Step < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    belongs_to :definition, class_name: 'Workflow::Definition::Step', optional: true
    belongs_to :process, class_name: 'Workflow::Instance::Process', counter_cache: true
    has_one :document, as: :documentable

    after_save :update_completed_counter_cache
    after_destroy :update_completed_counter_cache

    def title
      super || self.definition.try(:title)
    end

    def description
      self.definition.try(:description)
    end

    def kind
      super || self.definition.try(:kind)
    end

    def document
      super || self.definition.try(:document)
    end

    def position
      super || self.definition.try(:position)
    end

    private

    def update_completed_counter_cache
      self.process.completed_steps_count = Workflow::Instance::Step.where(completed: true, process_id: process.id).count
      self.process.save
    end
  end
end
