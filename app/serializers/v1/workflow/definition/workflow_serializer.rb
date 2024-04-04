class V1::Workflow::Definition::WorkflowSerializer < ApplicationSerializer
  set_id :id

  attributes :name, :description, :version, :created_at

  attribute :num_of_versions do |workflow|
    Workflow::Definition::Workflow.where(name: workflow.name).count
  end

  attribute :num_of_instances do |workflow|
    workflow.instances.count
  end

  attribute :published do |workflow|
    workflow.published?
  end
  
  has_many :processes, serializer: V1::Workflow::Definition::BasicProcessSerializer do |workflow, params|
    workflow.processes.includes(:taggings, :categories).order(:position)
  end
end
