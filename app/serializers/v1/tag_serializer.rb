# frozen_string_literal: true

module V1
  class TagSerializer < ApplicationSerializer
    attributes :name, :description
  end
end
