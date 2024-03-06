FactoryBot.define do
  factory :workflow_definition_process, class: 'Workflow::Definition::Process' do
    title { Faker::Company.name }
    description { Faker::Lorem.paragraph }

    # after(:create) do |process|
    #   w = create(:workflow_definition_workflow)
    #   w.processes << process
    # end
  end
end
