FactoryBot.define do
  factory :audience do
    name { Faker::Color.color_name.capitalize }
    description { Faker::Lorem.paragraphs }
  end
  factory :role do
    name { Faker::Company.profession }
    description { Faker::Lorem.paragraphs }
  end
  factory :category do
    name { Faker::Educator.subject }
    description { Faker::Lorem.paragraphs }
  end
end
