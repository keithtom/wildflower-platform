FactoryBot.define do
  factory :workflow_instance_step_assignment, class: 'Workflow::Instance::StepAssignment' do
    association :step, factory: :workflow_instance_step
    association :assignee, factory: :person
  end
end
