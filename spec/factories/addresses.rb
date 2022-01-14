FactoryBot.define do
  factory :address do
    line1 { Faker::Address.street_address }
    line2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip { Faker::Address.zip }
    country { Faker::Address.country }
  end
end
