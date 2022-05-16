FactoryBot.define do
  factory :advice_stakeholder, class: 'Advice::Stakeholder' do
    association :decision, factory: :advice_decision
    association :person, factory: :person
  end

  factory :external_advice_stakeholder, class: 'Advice::Stakeholder' do
    association :decision, factory: :advice_decision
    external_name { Faker::Name.name }
    external_email { Faker::Internet.email }
    external_phone { Faker::PhoneNumber.cell_phone }
    external_calendar_url { Faker::Internet.url }
    external_roles { Array.new(1+rand(2)).map { Faker::Job.title } }
    external_subroles { Array.new(2+rand(1)).map { Faker::Job.position } }
  end
end
