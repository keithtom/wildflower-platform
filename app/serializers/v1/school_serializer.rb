# frozen_string_literal: true

module V1
  class SchoolSerializer < ApplicationSerializer
    attributes :name

    has_one :address
  end
end
