FactoryBot.define do
  factory :workflow_definition_process, class: 'Workflow::Definition::Process' do
    title { "Planning" }
    after(:create) do |process|
      w = create(:workflow_definition_workflow)
      w.processes << process
    end
  end
end
