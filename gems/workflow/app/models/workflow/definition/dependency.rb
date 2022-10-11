module Workflow
  # For a given workflow, find the prequisite workable (process/step) for a given workable.
  class Definition::Dependency < ApplicationRecord
    belongs_to :workflow

    belongs_to :workable, polymorphic: true
    belongs_to :prequisite_workable, polymorphic: true
  end
end
