FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    
    trait :admin do
      is_admin { true }
    end

    trait :with_person do
      person { create(:person) }
    end
  end
end
