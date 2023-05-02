FactoryBot.define do
  factory :workflow_instance_process, class: 'Workflow::Instance::Process' do
    association :definition, factory: :workflow_definition_process
    association :workflow, factory: :workflow_instance_workflow
  end

  factory :workflow_instance_process_manual, class: 'Workflow::Instance::Process' do
    association :workflow, factory: :workflow_instance_workflow
    title { "Learn about the Advice Process" }
    description { "lorem ipsum" }
    position { 100 }
  end
end
