FactoryBot.define do
  factory :ssj_team, class: 'SSJ::Team' do |team|
    association :ops_guide, factory: :person
    association :regional_growth_lead, factory: :person
    association :workflow, factory: :workflow_instance_workflow

    factory :ssj_team_with_members do
      after(:create) do |ssj_team|
        create(:ssj_team_member, ssj_team: ssj_team)
        create(:ssj_team_member, ssj_team: ssj_team, person_id: ssj_team.ops_guide_id, role: SSJ::TeamMember::OPS_GUIDE)
        create(:ssj_team_member, ssj_team: ssj_team, person_id: ssj_team.regional_growth_lead_id, role: SSJ::TeamMember::RGL)
      end
    end
  end
end
