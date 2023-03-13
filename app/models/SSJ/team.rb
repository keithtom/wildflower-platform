class SSJ::Team < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  belongs_to :ops_guide, class_name: 'Person', foreign_key: 'ops_guide_id', required: false
  belongs_to :regional_growth_lead, class_name: 'Person', foreign_key: 'regional_growth_lead_id', required: false

  has_many :ssj_team_members, class_name: "SSJ::TeamMember", foreign_key: 'ssj_team_id'
  has_many :people, through: :ssj_team_members do
    def current
      where('ssj_team_members.current = ?', true)
    end

    def partners
      where('ssj_team_members.role = ?', 'partner')
    end
  end

  belongs_to :workflow, class_name: "Workflow::Instance::Workflow"
end
