# frozen_string_literal: true

module V1
  class RoleSerializer < ApplicationSerializer
    attributes :name, :description
  end
end