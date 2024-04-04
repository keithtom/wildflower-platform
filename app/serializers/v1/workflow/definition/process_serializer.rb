class V1::Workflow::Definition::ProcessSerializer < ApplicationSerializer
  include V1::Categorizable

  set_id :id

  attributes :title, :description, :version

  attribute :phase do |process|
    process.phase_list.first
  end

  has_many :steps, serializer: V1::Workflow::Definition::StepSerializer do |process|
    process.steps.by_position
  end

  has_many :selected_processes, serializer: V1::Workflow::Definition::SelectedProcessSerializer do |process|
    process.selected_processes.order(:position)
  end

  has_many :prerequisites, serializer: V1::Workflow::Definition::ProcessSerializer do |process|
    process.prerequisites
  end

  attribute :categories do |process|
    get_categories(process)
  end

  attribute :num_of_instances do |process|
    process.instances.count
  end
end
