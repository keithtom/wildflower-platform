FactoryBot.define do
  factory :workflow_definition_step, class: 'Workflow::Definition::Step' do
    association :process, factory: :workflow_definition_process
    title { Faker::Company.bs }
    description { Faker::Lorem.paragraph }
    kind { Workflow::Definition::Step::DEFAULT }
    completion_type { Workflow::Definition::Step::EACH_PERSON }
    min_worktime { rand(100) * 60 * 60}
    max_worktime { (100+rand(100)) * 60 * 60}
    decision_question { Faker::Lorem.sentence }
    
    after(:create) { |step| create(:document, documentable: step) }
  end

  factory :workflow_definition_step_decision, class: 'Workflow::Definition::Step' do
    association :process, factory: :workflow_definition_process
    title { Faker::Company.bs }
    description { Faker::Lorem.paragraph }
    kind { Workflow::Definition::Step::DECISION }
    position { Workflow::Definition::Step::DEFAULT_INCREMENT }
    completion_type { Workflow::Definition::Step::EACH_PERSON }
    min_worktime { rand(100) * 60 * 60}
    max_worktime { (100+rand(100)) * 60 * 60}
    decision_question { Faker::Lorem.sentence }
    
    after(:create) { |step| Workflow::DecisionOption.create(decision: step) }
  end
end
