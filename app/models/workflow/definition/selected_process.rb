module Workflow
  # join table for workflow and process
  class Definition::SelectedProcess < ApplicationRecord
    audited

    belongs_to :workflow
    belongs_to :process
  end
end
