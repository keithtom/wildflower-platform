# frozen_string_literal: true

module V1
  class TagSerializer < ApplicationSerializer
    set_id :name # temporary hack to get things working, but need to figure out unique id
    attributes :name, :description # ever needs an external serializer? isn't the name unique?
  end
end
