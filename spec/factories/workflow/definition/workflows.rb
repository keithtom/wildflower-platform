FactoryBot.define do
  factory :workflow_definition_workflow, class: 'Workflow::Definition::Workflow' do
    version { "v1" }
    name { Faker::Books::Dune.character }
    description { "Imagine the school of your dreams" }
  end
end
