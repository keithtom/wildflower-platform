FactoryBot.define do
  factory :workflow_definition_workflow, class: 'Workflow::Definition::Workflow' do
    sequence(:version) { |n| "v#{n}" }
    sequence(:name) { |n| "Workflow #{n}" }
    description { 'Imagine the school of your dreams' }
    trait :with_recurring_processes do
      after(:create) do |workflow_definition_workflow|
        create_list(:selected_process_for_recurring, 3, workflow: workflow_definition_workflow)
      end
    end
    trait :with_processes do
      after(:create) do |workflow_definition_workflow|
        create_list(:selected_process, 3, workflow: workflow_definition_workflow)
      end
    end
  end
end
