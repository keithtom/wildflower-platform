FactoryBot.define do
  factory :advice_message, class: 'Advice::Message' do
    association :decision, factory: :open_advice_decision
    association :sender, factory: :advice_stakeholder
    association :stakeholder, factory: :advice_stakeholder
    content { Faker::Lorem.paragraph }
  end
end
