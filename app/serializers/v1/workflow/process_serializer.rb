class V1::Workflow::ProcessSerializer < ApplicationSerializer
  include V1::Statusable
  include V1::Categorizable

  attributes :title, :position, :steps_count, :completed_steps_count, :description

  attribute :status do |process|
    process_status(process)
  end

  attribute :categories do |process|
    get_categories(process)
  end

  attribute :phase do |process|
    process.definition.phase_list.first
  end

  attribute :steps_assigned_count do |process|
    process.steps.where.not(assignee_id: nil).count
  end

  belongs_to :workflow, serializer: V1::Workflow::WorkflowSerializer, id_method_name: :external_identifier do |process|
    process.workflow
  end

  has_many :steps, serializer: V1::Workflow::StepSerializer, id_method_name: :external_identifier do |process, params|
    if params[:assignee_id]
      process.steps.where(assignee_id: params[:assignee_id], completed: false)
    else
      process.steps
    end
  end

  has_many :prerequisite_processes, if: Proc.new { |process, params| params && params[:prerequisites] }, serializer: V1::Workflow::ProcessSerializer, id_method_name: :external_identifier do |process|
    process.prerequisites
  end
  
end
