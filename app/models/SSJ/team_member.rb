class SSJ::TeamMember < ApplicationRecord
  belongs_to :person
  belongs_to :ssj_team, class_name: "SSJ::Team", foreign_key: 'ssj_team_id'
end
