FactoryBot.define do
  factory :workflow_decision_option, class: 'Workflow::DecisionOption' do
    association :decision, factory: :workflow_definition_step
    description { Faker::Lorem.sentence }
  end
end
