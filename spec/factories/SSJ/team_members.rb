FactoryBot.define do
  factory :ssj_team_member, class: 'SSJ::TeamMember' do |team_member|
    person
    ssj_team
    role { SSJ::TeamMember::PARTNER }
    status { SSJ::TeamMember::ACTIVE }
  end
end
