class SSJ::Team < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  belongs_to :

  has_many :people, foreign_key: :ssj_team_id
  belongs_to :workflow, class_name: "Workflow::Instance::Workflow"
end
