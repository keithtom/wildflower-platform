FactoryBot.define do
  factory :workflow_definition_process, class: 'Workflow::Definition::Process' do
    title { Faker::Company.name }
    description { Faker::Lorem.paragraph }
    phase_list { [SSJ::Phase::PHASES.sample] }
    category_list { [SSJ::Category::CATEGORIES.sample] }
  end
end
