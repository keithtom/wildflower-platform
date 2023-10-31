FactoryBot.define do
  factory :workflow_definition_workflow, class: 'Workflow::Definition::Workflow' do
    version { "v1" }
    name { "National, Independent Sensible Default" }
    description { "Imagine the school of your dreams" }
  end
end
