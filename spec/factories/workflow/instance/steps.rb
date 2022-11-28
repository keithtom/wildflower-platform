FactoryBot.define do
  factory :workflow_instance_step, class: 'Workflow::Instance::Step' do
    association :definition, factory: :workflow_definition_step
  end

  factory :workflow_instance_step_manual, class: 'Workflow::Instance::Step' do
    association :document, factory: :document
    title { "Watch Building a Wildflower Budget " }
    kind { "default" }
    position { 100 }
  end
end
