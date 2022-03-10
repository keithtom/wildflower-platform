FactoryBot.define do
  factory :school_relationship do
    # entrepeneur, board member, founder, employee? overlaps w/ experience a bit...

    association :person
    association :school

    name { Faker::Lorem.word.titleize }
    description { Faker::Lorem.paragraphs }
    start_date { Faker::Date.between(from: 5.years.ago, to: 3.months.ago) }
    end_date { Faker::Date.between(from: 3.months.ago, to: 1.month.ago) }
  end
end
