class V1::Workflow::Definition::DependencySerializer < ApplicationSerializer
  set_id :id

  attributes :id, :workflow_id, :workable_type, :workable_id, :prerequisite_workable_type, 
    :prerequisite_workable_id, :created_at, :updated_at
end