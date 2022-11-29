FactoryBot.define do
  factory :workflow_instance_workflow, class: 'Workflow::Instance::Workflow' do
    association :definition, factory: :workflow_definition_workflow
  end
end
