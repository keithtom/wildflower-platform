FactoryBot.define do
  factory :advice_decision, class: 'Advice::Decision' do
    association :creator, factory: :person
    state { Advice::Decision::DRAFT }

    factory :draft_advice_decision do
      title { Faker::Lorem.sentence }
      role { "finance" }
      context { Faker::Lorem.paragraph(sentence_count: 4 + rand(4)) }
      proposal { Faker::Lorem.paragraph(sentence_count: 4 + rand(4)) }

      factory :open_advice_decision do
        state { Advice::Decision::OPEN }
        decide_by { (14 + rand(4)).days.from_now }
        advice_by { (7 + rand(4)).days.from_now }

        after :create do |decision|
          create :document, documentable: decision
          create :advice_event, decision: decision, originator: decision.creator, name: Advice::Decision::OPEN
          stakeholder = create :advice_stakeholder, decision: decision
          create :advice_message, decision: decision, sender: decision.creator, stakeholder: stakeholder, content: "Hello! How's it going?"
          create :advice_message, decision: decision, sender: stakeholder, stakeholder: stakeholder, content: "Hi! Well, thank you!"
          create :advice_record, decision: decision, stakeholder: stakeholder
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
end
