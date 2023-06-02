FactoryBot.define do
  factory :tag, class: "ActsAsTaggableOn::Tag" do
    name { Faker::Lorem.word }
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
