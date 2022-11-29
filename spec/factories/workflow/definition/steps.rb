FactoryBot.define do
  factory :workflow_definition_step, class: 'Workflow::Definition::Step' do
    association :process, factory: :workflow_definition_process
    title { "Watch Building a Wildflower Budget " }
    description { "watch video in its entirety" }
    kind { "default" }
    position { 100 }

    after(:create) { |step| create(:document, documentable: step) }
  end
end
