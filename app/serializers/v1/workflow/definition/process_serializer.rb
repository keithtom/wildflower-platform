class V1::Workflow::Definition::ProcessSerializer < ApplicationSerializer
  include V1::Categorizable

  set_id :id

  attributes :title, :description, :version, :duration, :due_months, :recurring

  attribute :phase do |process|
    process.phase_list.first
  end

  attribute :published do |process|
    process.published?
  end

  has_many :steps, serializer: V1::Workflow::Definition::StepSerializer do |process|
    process.steps.by_position
  end

  has_many :selected_processes, serializer: V1::Workflow::Definition::SelectedProcessSerializer do |process, params|
    if params[:workflow_id]
      process.selected_processes.order(:position).where(workflow_id: params[:workflow_id])
    else
      process.selected_processes.order(:position)
    end
  end

  has_many :prerequisites, serializer: V1::Workflow::Definition::ProcessSerializer do |process, params|
    if params[:workflow_id]
      process.prerequisites.merge(Workflow::Definition::Dependency.where(workflow_id: params[:workflow_id]))
    else
      process.prerequisites
    end
  end

  has_many :workable_dependencies, serializer: V1::Workflow::Definition::DependencySerializer do |process, params|
    if params[:workflow_id]
      process.workable_dependencies.where(workflow_id: params[:workflow_id])
    else
      process.workable_dependencies
    end
  end

  attribute :categories do |process|
    get_categories(process)
  end

  attribute :num_of_instances do |process|
    process.instances.count
  end
end
