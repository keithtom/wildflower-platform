FactoryBot.define do
  factory :workflow_definition_step, class: 'Workflow::Definition::Step' do
    association :process, factory: :workflow_definition_process
    title { Faker::Company.bs }
    description { Faker::Lorem.paragraph }
    kind {Workflow::Definition::Step::DEFAULT }
    position { Workflow::Definition::Step::DEFAULT_INCREMENT }
    completion_type { Workflow::Definition::Step::EACH_PERSON }

    after(:create) { |step| create(:document, documentable: step) }
  end
end
