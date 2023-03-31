module Workflow
  # an instance of a step can be assigned to a worker (person) and completed by that person.
  class Instance::StepAssignment < ApplicationRecord
    belongs_to :step
    belongs_to :assignee, class_name: 'Person'

    # for decision steps, we record the assignee's choice
    belongs_to :selected_option, class_name: 'Workflow::DecisionOption', optional: true

    scope :for_workflow, ->(workflow_id) { joins(step: { process: :workflow }).where(workflows: { id: workflow_id }) }
  end
end