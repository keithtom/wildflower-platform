FactoryBot.define do
  factory :advice_event, class: 'Advice::Event' do
    association :decision, factory: :advice_decision
    association :originator, factory: :person
    name { "Request Advice Again" }
    description { Faker::Lorem.paragraph }
  end
end
