FactoryBot.define do
  factory :definition_workflow, class: 'Definition::Workflow' do
    version 1
    name { "A journey from 0 to 1000" }
    description "Work your way through all the numbers."

  end
end
