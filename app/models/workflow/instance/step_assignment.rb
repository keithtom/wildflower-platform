module Workflow
  # an instance of a step can be assigned to a worker (person) and completed by that person.
  class Instance::StepAssignment < ApplicationRecord
    audited

    belongs_to :step
    belongs_to :assignee, class_name: 'Person'

    # for decision steps, we record the assignee's choice
    belongs_to :selected_option, class_name: 'Workflow::DecisionOption', optional: true

    scope :for_person_id, ->(person_id) { where(assignee_id: person_id) }

    scope :for_workflow, ->(workflow_id) { joins(step: { process: :workflow }).where("workflow_instance_workflows.id = ?", workflow_id) }
    scope :complete, -> { where.not(completed_at: nil) }
    scope :incomplete, -> { where(completed_at: nil) }
  end
end