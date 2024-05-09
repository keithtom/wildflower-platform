module Workflow
  # join table for workflow and process
  class Definition::SelectedProcess < ApplicationRecord
    include AASM
    acts_as_paranoid
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
      state :replicated, :removed, :upgraded, :added, :repositioned
    
      event :replicate do
        transitions from: :initialized, to: :replicated
      end
    
      event :remove do
        transitions from: [:replicated, :repositioned], to: :removed
      end
    
      event :reposition do
        transitions from: [:added, :replicated, :repositioned], to: :repositioned
      end
    
      event :revert do
        before do
          revert_to_previous_version
        end
        transitions from: [:removed, :upgraded, :repositioned], to: :replicated
      end
    
      event :upgrade do
        transitions from: [:replicated, :repositioned], to: :upgraded
      end
    
      event :add do
        transitions from: :initialized, to: :added
      end
    end

    private

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
  
    def revert_to_previous_version
      if upgraded?
        process.destroy!
      end

      self.process = previous_version&.process
      self.position = previous_version&.position
    end
  end
end
