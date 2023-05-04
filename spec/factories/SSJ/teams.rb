FactoryBot.define do
  factory :ssj_team, class: 'SSJ::Team' do |team|
    association :ops_guide, factory: :person
    association :regional_growth_lead, factory: :person
    association :workflow, factory: :workflow_instance_workflow
  end
end
