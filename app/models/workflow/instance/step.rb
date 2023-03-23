module Workflow
  class Instance::Step < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    belongs_to :definition, class_name: 'Workflow::Definition::Step', optional: true # for manual steps.
    belongs_to :process, counter_cache: true

    has_many :step_assignments
    has_many :assignees, through: :step_assignments, source: :assignee
    
    has_many :documents, as: :documentable
    belongs_to :selected_option, class_name: 'Workflow::DecisionOption', optional: true

    before_create :set_position
    after_save :update_process
    after_destroy :update_process

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
      super.empty? ? self.definition.try(:documents) : super
    end

    def position
      super || self.definition.try(:position)
    end

    def is_manual?
      definition.nil?
    end

    private

    def update_process
      update_process_completed_counter_cache
      update_process_completion_status
    end

    def update_process_completed_counter_cache
      self.process.completed_steps_count = Workflow::Instance::Step.where(completed: true, process_id: process.id).count
      self.process.save
    end

    def update_process_completion_status
      case process.completed_steps_count
      when 0
        if process.assigned_and_incomplete?
          self.process.in_progress!
        else
          self.process.unstarted!
        end
      when process.steps_count
        self.process.done!
      else
        self.process.in_progress!
      end
    end

    def set_position
      if self.position.nil?
        self.position = self.process.steps.order(:position).last.try(:position).to_i + DEFAULT_INCREMENT
      end
    end
  end
end
