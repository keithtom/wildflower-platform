FactoryBot.define do
  factory :school do
    name { Faker::Educator.primary_school }
    website { Faker::Internet.domain_name }
    phone { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }

    governance_type { School::Governance::TYPES.sample }
    tuition_assistance_type { School::TuitionAssistance::TYPES.sample }  # should be easily searched, and multiple
    ages_served { School::AgesServed::TYPES.sample } # should be easily searched, and multiple
    calendar { School::Calendar::TYPES.sample }
    max_enrollment { (10..12).to_a.sample }
  end
end
