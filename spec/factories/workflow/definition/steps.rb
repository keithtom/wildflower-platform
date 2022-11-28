FactoryBot.define do
  factory :workflow_definition_step, class: 'Workflow::Definition::Step' do
    association :document, factory: :document
    title { "Watch Building a Wildflower Budget " }
    description { "watch video in its entirety" }
    kind { "default" }
    position { 100 }
  end
end
