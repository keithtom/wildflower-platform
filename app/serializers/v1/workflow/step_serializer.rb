class V1::Workflow::StepSerializer < ApplicationSerializer
  attributes :title, :completed, :kind, :resource_url, :resource_title, :position

  belongs_to :process, serializer: V1::Workflow::ProcessSerializer, record_type: :workflow_instance_process,
    id_method_name: :external_identifier do |step|
      step.process
  end
end
