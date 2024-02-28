class V1::Workflow::Definition::ProcessSerializer < ApplicationSerializer
  include V1::Categorizable

  set_id :id

  attributes :title, :description, :version, :position

  attribute :phase do |process|
    process.phase_list.first
  end

  attribute :categories do |process|
    get_categories(process)
  end
end
