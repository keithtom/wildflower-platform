class SSJ::TeamMember < ApplicationRecord
  belongs_to :person
  belongs_to :ssj_team, class_name: "SSJ::Team", foreign_key: 'ssj_team_id'

  ROLES = [PARTNER = "partner", OPS_GUIDE = "ops_guide", RGL = "regional_growth_lead"]
  STATUS = [INVITED = "invited", ACTIVE = "active"]
end
