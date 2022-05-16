FactoryBot.define do
  factory :advice_decision, class: 'Advice::Decision' do
    association :creator, factory: :person
    state { Advice::Decision::DRAFT }

    factory :draft_advice_decision do
      title { Faker::Lorem.sentence }
      role { "finance" }
      context { Faker::Lorem.paragraph }
      proposal { Faker::Lorem.paragraph }
      links { Array.new(rand(3)).map { Faker::Internet.url } }

      factory :open_advice_decision do
        state { Advice::Decision::OPEN }
        decide_by { (14 + rand(4)).days.from_now }
        advice_by { (7 + rand(4)).days.from_now }
      end

      factory :closed_advice_decision do
        state { Advice::Decision::CLOSED }
        decide_by { (0 + rand(2)).days.ago }
        advice_by { (7 + rand(4)).days.ago }
        final_summary { Faker::Lorem.paragraph }
      end
    end
  end
end
