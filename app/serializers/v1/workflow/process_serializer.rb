class V1::Workflow::ProcessSerializer < ApplicationSerializer
  attributes :title, :effort, :categories, :status, :position #, :assignee

  belongs_to :workflow, record_type: :workflow_instance_workflow, id_method_name: :workflow_instance_workflow_id,
    serializer: V1::Workflow::WorkflowSerializer

  has_many :steps, serializer: V1::Workflow::StepSerializer, record_type: :workflow_instance_step
end
