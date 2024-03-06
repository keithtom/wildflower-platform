module Workflow
  # join table for workflow and process
  class Definition::SelectedProcess < ApplicationRecord
    audited
    DEFAULT_INCREMENT = 1000

    belongs_to :workflow
    belongs_to :process

    before_create :set_position

    def set_position
      if self.position.nil?
        self.position = self.workflow.selected_processes.order(:position).last.try(:position).to_i + ::Workflow::Definition::SelectedProcess::DEFAULT_INCREMENT
      end
    end
  end
end
