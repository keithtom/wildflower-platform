class V1::Workflow::ProcessSerializer < ApplicationSerializer
  attributes :title, :effort, :categories, :status, :position #, :assignee

  belongs_to :workflow, record_type: :workflow_instance_workflow, id_method_name: :external_identifier,
    serializer: V1::Workflow::WorkflowSerializer do |process|
      process.workflow
    end

  has_many :steps, serializer: V1::Workflow::StepSerializer, record_type: :workflow_instance_step,
    id_method_name: :external_identifier do |process|
      process.steps
    end
end
