class Person
  # Person logic specifically related to workflow
  module Workflow
    extend ActiveSupport::Concern # https://dev.to/software_writer/how-rails-concerns-work-and-how-to-use-them-gi6

    included do
      has_many :step_assignments, class_name: "Workflow::Instance::StepAssignment", foreign_key: 'assignee_id'
      
      has_many :assigned_steps, through: :step_assignments, class_name: "Workflow::Instance::Step", foreign_key: 'assignee_id' do
        def incomplete
          where("workflow_instance_step_assignments.completed_at IS NULL")
        end
      end
    end
  end
end