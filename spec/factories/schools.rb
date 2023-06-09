FactoryBot.define do
  factory :school do
    name { Faker::Educator.primary_school }
    logo_url { ["https://images.unsplash.com/photo-1525310072745-f49212b5ac6d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1365&q=80",
      "https://static.wixstatic.com/media/6c8ee3_bc4e34d1c5264682b1eea6cdbf6d437c~mv2.png/v1/fill/w_242,h_84,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/wild%20rose%20logo_2020-01.png",
      "https://www.astermontessori.com/images/logo.jpg",
      "https://images.squarespace-cdn.com/content/v1/5ff26e4666132f51deddb6d6/77f0fbd2-5ce7-42f0-93dc-73734a3e0e34/TheDahliaSchool-02.jpg?format=1500w",
    ].sample }
    association :address, factory: :address
    website { Faker::Internet.domain_name }
    phone { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }

    governance_type { School::Governance::TYPES.sample }
    tuition_assistance_type_list { School::TuitionAssistance::TYPES.sample }  # should be easily searched, and multiple
    ages_served_list { School::AgesServed::TYPES.sample } # should be easily searched, and multiple
    calendar { School::Calendar::TYPES.sample }
    max_enrollment { (10..12).to_a.sample }
  end
end
