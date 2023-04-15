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
  
  has_many :ops_guide_members, -> { where(role: SSJ::TeamMember::OPS_GUIDE) }, class_name: "SSJ::TeamMember", foreign_key: 'ssj_team_id'
  has_many :ops_guides, through: :ops_guide_members, source: :person

  has_many :rgl_members, -> { where(role: SSJ::TeamMember::RGL) }, class_name: "SSJ::TeamMember", foreign_key: 'ssj_team_id'
  has_many :rgls, through: :rgl_members, source: :person

  has_many :people, through: :team_members do
    def active
      where('ssj_team_members.status = ?', SSJ::TeamMember::ACTIVE)
    end
  end

  belongs_to :workflow, class_name: "Workflow::Instance::Workflow"
end
