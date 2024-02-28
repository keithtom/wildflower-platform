class V1::Workflow::Definition::WorkflowSerializer < ApplicationSerializer
  set_id :id

  attributes :name, :description, :version
end
