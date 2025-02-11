FactoryBot.define do
  factory :selected_process, class: 'Workflow::Definition::SelectedProcess' do
    association :workflow, factory: :workflow_definition_workflow
    association :process, factory: :workflow_definition_process
  end
  factory :selected_process_for_recurring, class: 'Workflow::Definition::SelectedProcess' do
    association :workflow, factory: :workflow_definition_workflow, recurring: true
    association :process, factory: :workflow_definition_process, due_months: [(1..12).to_a.sample], recurring: true,
                          duration: 1
  end
end
