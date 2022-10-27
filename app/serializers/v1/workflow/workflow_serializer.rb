class V1::Workflow::WorkflowSerializer < ApplicationSerializer
  attributes :name, :description, :version

  has_many :processes, serializer: V1::Workflow::ProcessSerializer, record_type: :workflow_instance_process, 
    id_method_name: :external_identifier do |workflow|
      workflow.processes
  end

  link :url
end
