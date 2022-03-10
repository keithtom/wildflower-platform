# frozen_string_literal: true

module V1
  class SchoolRelationshipSerializer < ApplicationSerializer
    attributes :name, :description, :start_date, :end_date
  end
end
