FactoryBot.define do
  factory :school do
    name { Faker::Educator.primary_school }
    website { Faker::Internet.domain_name }
    phone { Faker::PhoneNumber.phone_number}
    email { Faker::Internet.email }
  end
end