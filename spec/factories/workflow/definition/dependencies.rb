FactoryBot.define do
  factory :workflow_definition_dependency, class: 'Workflow::Definition::Dependency' do
    association :workflow, factory: :workflow_definition_workflow
    association :workable, factory: :workflow_definition_process
    association :prerequisite_workable, factory: :workflow_definition_process
  end
end