FactoryBot.define do
  factory :workflow_definition_workflow, class: 'Workflow::Definition::Workflow' do
    version { "v1" }
    name { "Visioning" }
    description { "your dream school" }
  end
end
