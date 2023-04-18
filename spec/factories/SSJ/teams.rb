FactoryBot.define do
  factory :ssj_team, class: 'SSJ::Team' do |team|
    association :ops_guide, factory: :person
    association :regional_growth_lead, factory: :person
    association :workflow, factory: :workflow_instance_workflow
    after(:build) do |team|
      SSJ::TeamMember.create!(person: create(:person), ssj_team: team, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::PARTNER)
      SSJ::TeamMember.create!(person: team.ops_guide, ssj_team: team, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::OPS_GUIDE)
      SSJ::TeamMember.create!(person: team.regional_growth_lead, ssj_team: team, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::RGL)
    end
  end
end
