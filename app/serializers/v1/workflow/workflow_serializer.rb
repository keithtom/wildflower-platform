class V1::Workflow::WorkflowSerializer < ApplicationSerializer
  attributes :name, :description, :version

  has_many :processes, serializer: V1::Workflow::ProcessSerializer, record_type: :workflow_instance_process

  link :url
end
