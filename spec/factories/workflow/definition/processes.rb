FactoryBot.define do
  factory :workflow_definition_process, class: 'Workflow::Definition::Process' do
    title { Faker::Company.name }
    description { Faker::Lorem.paragraph }

  end
end
