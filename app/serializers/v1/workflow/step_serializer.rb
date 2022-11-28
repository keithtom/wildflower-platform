class V1::Workflow::StepSerializer < ApplicationSerializer
  attributes :title, :completed, :kind, :position, :completed_at

  belongs_to :process, serializer: V1::Workflow::ProcessSerializer, record_type: :workflow_instance_process,
    id_method_name: :external_identifier do |step|
      step.process
  end

  has_many :documents, serializer: V1::DocumentSerializer, record_type: :document,
    id_method_name: :external_identifier do |step|
      step.documents
  end
end
