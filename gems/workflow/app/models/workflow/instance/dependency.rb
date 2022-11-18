module Workflow
  # For a given workflow, find the prerequisite workable (process/step) for a given workable.
  class Instance::Dependency < ApplicationRecord
    belongs_to :definition, class_name: 'Workflow::Definition::Dependency'
    belongs_to :workflow

    belongs_to :workable, polymorphic: true # the process or step
    belongs_to :prerequisite_workable, polymorphic: true # the required process or step to be completed first
  end
end
