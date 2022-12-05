# frozen_string_literal: true

class V1::Workflow::ResourceSerializer < ApplicationSerializer
  include V1::Categorizable
  attributes :title, :link, :updated_at

  attribute :categories do |resource|
    get_categories(resource.documentable.process)
  end
end
