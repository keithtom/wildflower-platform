require "ssj"

# Represents team membership
module SSJ
  class TeamMember < ApplicationRecord
    belongs_to :person
    belongs_to :ssj_team, class_name: "SSJ::Team", foreign_key: 'ssj_team_id'

    ROLES = [PARTNER = "partner", OPS_GUIDE = "ops_guide", RGL = "regional_growth_lead"]
    STATUS = [INVITED = "invited", ACTIVE = "active", INACTIVE = "inactive"]

    scope :active, -> { where(status: ACTIVE) }
    scope :invited, -> { where(status: INVITED) }
    scope :partners, -> { where(role: PARTNER) }
    scope :ops_guide, -> { where(role: OPS_GUIDE) }
    scope :rgl, -> { where(role: RGL) }

    # validates :role, inclusion: { in: ROLES }
    # validates :status, inclusion: { in: STATUS }
  end
end