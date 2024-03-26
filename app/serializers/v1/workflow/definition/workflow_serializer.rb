class V1::Workflow::Definition::WorkflowSerializer < ApplicationSerializer
  set_id :id

  attributes :name, :description, :version

  has_many :processes, serializer: V1::Workflow::Definition::BasicProcessSerializer do |workflow|
    workflow.processes.order(:position)
  end
end
