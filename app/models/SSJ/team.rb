class SSJ::Team < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  belongs_to :ops_guide, class_name: 'Person', foreign_key: 'ops_guide_id', required: false
  belongs_to :regional_growth_lead, class_name: 'Person', foreign_key: 'regional_growth_lead_id', required: false

  has_many :team_members, class_name: "SSJ::TeamMember", foreign_key: 'ssj_team_id'
  
  has_many :partner_members, -> { where(role: SSJ::TeamMember::PARTNER) }, class_name: "SSJ::TeamMember", foreign_key: 'ssj_team_id'
  has_many :partners, through: :partner_members, source: :person do
    def active
      where('ssj_team_members.status = ?', SSJ::TeamMember::ACTIVE)
    end
  end
  
  # has_one :ops_guide_member, -> { where(role: SSJ::TeamMember::OPS_GUIDE) }, class_name: "SSJ::TeamMember", foreign_key: 'ssj_team_id'
  # has_one :ops_guide, through: :ops_guide_member, source: :person

  # has_one :rgl_member, -> { where(role: SSJ::TeamMember::RGL) }, class_name: "SSJ::TeamMember", foreign_key: 'ssj_team_id'
  # has_one :rgl, through: :rgl_member, source: :person

  has_many :people, through: :team_members do
    def active
      where('ssj_team_members.status = ?', SSJ::TeamMember::ACTIVE)
    end

    def partners
      where('ssj_team_members.role = ?', SSJ::TeamMember::PARTNER)
    end
  end

  belongs_to :workflow, class_name: "Workflow::Instance::Workflow"
end
