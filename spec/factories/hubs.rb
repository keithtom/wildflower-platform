FactoryBot.define do
  factory :hub do
    name { Faker::Address.state }
    entrepreneur { create(:person) }
  end
end
