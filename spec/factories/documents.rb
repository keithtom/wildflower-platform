FactoryBot.define do
  factory :document do
    title { Faker::Book.title }
    link { Faker::Internet.url }
  end
end
