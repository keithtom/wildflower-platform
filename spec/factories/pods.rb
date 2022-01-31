FactoryBot.define do
  factory :pod do
    name { Faker::Mountain.name }
    association :hub
    primary_contact { create(:person) }
  end
end
