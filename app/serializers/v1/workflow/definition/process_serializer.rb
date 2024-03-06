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

  attribute :categories do |process|
    get_categories(process)
  end
end
