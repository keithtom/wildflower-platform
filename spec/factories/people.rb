FactoryBot.define do
  factory :person do
    email { Faker::Internet.unique.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { Faker::PhoneNumber.phone_number }
    role_list { [Person::MAIN_ROLES.sample] }
    about { "Hi there! I decided to pursue being a teacher leader 3 years ago #{Faker::Lorem.paragraph}" }
    association :address, factory: :address

    trait :og do
      after(:create) do |person|
        person.role_list.add(Person::OPS_GUIDE)
        create(:ssj_team_member, person: person, ssj_team: create(:ssj_team), role: SSJ::TeamMember::OPS_GUIDE)
        create(:ssj_team_member, person: person, ssj_team: create(:ssj_team), role: SSJ::TeamMember::OPS_GUIDE)
        create(:ssj_team_member, person: person, ssj_team: create(:ssj_team), role: SSJ::TeamMember::OPS_GUIDE)
      end
    end

    factory :og_person, traits: [:og]
  end

  factory :person_with_school, parent: :person do
    after(:create) do |person|
      create(:school_relationship, person: person)
    end
  end
end
