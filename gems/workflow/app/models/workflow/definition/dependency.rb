module Workflow
  # For a given workflow, find the prerequisite workable (process/step) for a given workable.
  class Definition::Dependency < ApplicationRecord
    belongs_to :workflow

    belongs_to :workable, polymorphic: true
    belongs_to :prerequisite_workable, polymorphic: true

    has_many :instances, class_name: 'Workflow::Instance::Dependency', foreign_key: 'definition_id'
  end
end
