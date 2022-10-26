class ProcessSerializer
  include JSONAPI::Serializer

  attributes :title, :effort, :categories, :status, :position #, :assignee

  belongs_to :workflow, record_type: :workflow_instance_workflow, id_method_name: :workflow_instance_workflow_id,
    serializer: WorkflowSerializer

  has_many :steps, serializer: StepSerializer, record_type: :workflow_instance_step
end
