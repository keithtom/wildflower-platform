module Workflow
  # an instance of a step can be assigned to a worker (person) and completed by that person.
  class Instance::StepAssignment < ApplicationRecord
    belongs_to :step
    belongs_to :assignee, class_name: 'Person'
  end
end