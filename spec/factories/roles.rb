FactoryBot.define do
  factory :role do
    name { Faker::Color.color_name.capitalize }
    description { Faker::Lorem.paragraphs }
  end
end
