module Workflow
  # join table for workflow and process
  class Definition::SelectedProcess < ApplicationRecord
    include AASM
    audited
    DEFAULT_INCREMENT = 1000

    belongs_to :workflow
    belongs_to :process

    belongs_to :previous_version, class_name: 'Workflow::Definition::SelectedProcess', foreign_key: 'previous_version_id', optional: true
    has_one :next_version, class_name: 'Workflow::Definition::SelectedProcess', foreign_key: 'previous_version_id'

    before_create :set_position
    before_destroy :validate_destroyable

    aasm column: :state do
      state :initialized, initial: true 
      state :replicated, :removed, :upgraded, :added
    
      event :replicate do
        transitions from: :initialized, to: :replicated
      end
    
      event :remove do
        transitions from: :replicated, to: :removed
      end
    
      event :revert do
        transitions from: [:removed, :upgraded], to: :replicated
      end
    
      event :upgrade do
        transitions from: :replicated, to: :upgraded
      end
    
      event :add do
        transitions from: :initialized, to: :added
      end
    end

    def set_position
      if self.position.nil?
        self.position = self.workflow.selected_processes.order(:position).last.try(:position).to_i + ::Workflow::Definition::SelectedProcess::DEFAULT_INCREMENT
      end
    end
  
    def validate_destroyable
      unless initialized? || added?
        raise StandardError.new("Cannot delete in current state: #{state}")
      end
    end
  end
end
