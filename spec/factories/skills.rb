FactoryBot.define do
  factory :skill do
    name { Faker::Job.key_skill.capitalize }
    description { Faker::Lorem.paragraphs }
  end
end
