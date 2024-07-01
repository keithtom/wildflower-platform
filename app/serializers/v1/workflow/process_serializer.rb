class V1::Workflow::ProcessSerializer < ApplicationSerializer
  include V1::Statusable
  include V1::Categorizable

  attributes :title, :position, :steps_count, :completed_steps_count, :description, :suggested_start_date, :due_date, :recurring_type

  attribute :status do |process|
    process_status(process)
  end

  attribute :categories do |process|
    get_categories(process)
  end

  attribute :phase do |process|
    process.definition.phase_list.first
  end

  # update this.
  attribute :steps_assigned_count do |process|
    process.steps.assigned.count
  end

  belongs_to :workflow, serializer: V1::Workflow::WorkflowSerializer, id_method_name: :external_identifier do |process|
    process.workflow
  end

  has_many :steps, serializer: V1::Workflow::StepSerializer, id_method_name: :external_identifier do |process, params|
    process.steps.by_position
  end

  has_many :prerequisite_processes, if: Proc.new { |process, params| params && params[:prerequisites] }, serializer: V1::Workflow::ProcessSerializer, id_method_name: :external_identifier do |process|
    process.prerequisites.by_position
  end
end
