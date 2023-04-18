FactoryBot.define do
  factory :workflow_instance_step, class: 'Workflow::Instance::Step' do
    association :definition, factory: :workflow_definition_step
    association :process, factory: :workflow_instance_process
    completion_type { Workflow::Definition::Step::EACH_PERSON }
  end

  factory :workflow_instance_step_manual, class: 'Workflow::Instance::Step' do
    association :process, factory: :workflow_instance_process
    title { "Watch Building a Wildflower Budget " }
    kind { "default" }
    position { Workflow::Definition::Step::DEFAULT_INCREMENT }
    completion_type { Workflow::Definition::Step::ONE_PER_GROUP }

    after(:build) { |step| create(:document, documentable: step) }
  end
end

