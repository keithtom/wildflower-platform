class V1::Workflow::ProcessSerializer < ApplicationSerializer
  include V1::Statusable
  include V1::Categorizable

  attributes :title, :effort, :position, :steps_count, :completed_steps_count, :description

  attribute :status do |process|
    status(process)
  end

  attribute :categories do |process|
    get_categories(process)
  end

  attribute :steps_assigned_count do |process|
    process.steps.where.not(assignee_id: nil).count
  end

  belongs_to :workflow, record_type: :workflow_instance_workflow, id_method_name: :external_identifier,
    serializer: V1::Workflow::WorkflowSerializer do |process|
      process.workflow
    end

  has_many :steps, record_type: :workflow_instance_step, id_method_name: :external_identifier,
    serializer: V1::Workflow::StepSerializer do |process, params|
      if params[:assignee_id]
        process.steps.where(assignee_id: params[:assignee_id], completed: false)
      else
        process.steps
      end
    end
end
