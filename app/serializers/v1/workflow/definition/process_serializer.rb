class V1::Workflow::Definition::ProcessSerializer < ApplicationSerializer
  set_id :id

  attributes :title, :description, :version, :position
end
