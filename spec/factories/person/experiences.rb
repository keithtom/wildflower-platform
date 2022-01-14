FactoryBot.define do
  factory :person_experience, class: 'Person::Experience' do
    association :person
    association :school

    name { Faker::Lorem.word.titleize }
    description { Faker::Lorem.paragraphs }
    start_date { Faker::Date.between(from: 5.years.ago, to: 3.months.ago) }
    end_date { }
  end
end
