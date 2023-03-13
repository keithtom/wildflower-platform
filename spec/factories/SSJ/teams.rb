FactoryBot.define do
  factory :ssj_team, class: 'SSJ::Team' do |team|
    association :ops_guide, factory: :person
    association :regional_growth_guide, factory: :person
    trait :with_partners do
      partners { build_list :person, 2 }
    end
  end
end
