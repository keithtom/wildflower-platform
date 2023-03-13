class SSJ::Team < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  belongs_to :ops_guide, class_name: 'Person', foreign_key: 'ops_guide_id', required: false
  belongs_to :regional_growth_lead, class_name: 'Person', foreign_key: 'regional_growth_lead_id', required: false
  has_many :partners, class_name: 'Person', foreign_key: :ssj_team_id
  belongs_to :workflow, class_name: "Workflow::Instance::Workflow"

  def members
    [ops_guide, regional_growth_lead] + partners
  end
end
