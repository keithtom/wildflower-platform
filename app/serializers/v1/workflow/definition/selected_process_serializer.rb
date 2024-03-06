class V1::Workflow::Definition::SelectedProcessSerializer < ApplicationSerializer
  set_id :id

  attributes :workflow_id, :process_id, :position
end