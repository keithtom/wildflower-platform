FactoryBot.define do
  factory :workflow_definition_workflow, class: 'Workflow::Definition::Workflow' do
    version { "v1" }
    name { Faker::Book::title }
    description { "Imagine the school of your dreams" }
  end
end
