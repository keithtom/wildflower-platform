# frozen_string_literal: true

class V1::Workflow::ResourceSerializer < ApplicationSerializer
  attributes :title, :link, :updated_at

  attribute :categories do |resource|
    resource.documentable.process.category_list
  end
end
