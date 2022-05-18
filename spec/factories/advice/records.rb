FactoryBot.define do
  factory :advice_record, class: 'Advice::Record' do
    association :decision, factory: :open_advice_decision
    association :stakeholder, factory: :advice_stakeholder
    content { Faker::Lorem.paragraph }
    status { Advice::Record::NO_OBJECTION }
  end
end
