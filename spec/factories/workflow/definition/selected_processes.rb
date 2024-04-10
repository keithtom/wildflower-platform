FactoryBot.define do
  factory :selected_process, class: Workflow::Definition::SelectedProcess do
    association :workflow, factory: :workflow_definition_workflow
    association :process, factory: :workflow_definition_process
  end
end
