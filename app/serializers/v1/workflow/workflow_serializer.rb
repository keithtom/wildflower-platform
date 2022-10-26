class V1::Workflow::WorkflowSerializer < ApplicationSerializer
  attributes :name, :description

  has_many :processes, serializer: ProcessSerializer, record_type: :workflow_instance_process

  link :url
end
