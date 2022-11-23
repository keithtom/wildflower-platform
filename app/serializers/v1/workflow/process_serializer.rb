class V1::Workflow::ProcessSerializer < ApplicationSerializer
  include V1::Statusable

  attributes :title, :effort, :categories, :position, :steps_count, :completed_steps_count #, :assignee

  attribute :status do |process|
    status(process)
  end

  belongs_to :workflow, record_type: :workflow_instance_workflow, id_method_name: :external_identifier,
    serializer: V1::Workflow::WorkflowSerializer do |process|
      process.workflow
    end

  has_many :steps, record_type: :workflow_instance_step, id_method_name: :external_identifier,
    serializer: V1::Workflow::StepSerializer do |process|
      process.steps
    end

  belongs_to :assignee, record_type: :people, id_method_name: :external_identifier,
    serializer: V1::PersonSerializer do |process|
    process.assignee
  end
end
