FactoryBot.define do
  factory :ssj_team_member, class: 'SSJ::TeamMember' do
    association :person, factory: :person
    association :ssj_team, factory: :ssj_team
    role { SSJ::TeamMember::PARTNER}
    status { SSJ::TeamMember::ACTIVE }
  end
end
