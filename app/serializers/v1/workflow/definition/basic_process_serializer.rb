class V1::Workflow::Definition::BasicProcessSerializer < ApplicationSerializer
  include V1::Categorizable

  set_id :id

  attributes :title, :version

  attribute :phase do |process|
    process.phase_list.first
  end

  attribute :published do |process|
    process.published?
  end

  attribute :num_of_steps do |process|
    process.steps.count
  end

  attribute :categories do |process|
    get_categories(process)
  end

  attribute :is_prerequisite do |process, params|
    if params[:workflow_id]
      !Workflow::Definition::Dependency.where(workflow_id: params[:workflow_id], prerequisite_workable_id: process.id, prerequisite_workable_type: process.class.to_s).empty?
    end
  end

  attribute :prerequisite_titles do |process, params|
    if params[:workflow_id]
      process.prerequisites.merge(Workflow::Definition::Dependency.where(workflow_id: params[:workflow_id])).pluck(:title)
    end
  end

  has_many :selected_processes, serializer: V1::Workflow::Definition::SelectedProcessSerializer do |process, params|
    if params[:workflow_id]
      process.selected_processes.where(workflow_id: params[:workflow_id]).order(:position)
    end
  end
end
