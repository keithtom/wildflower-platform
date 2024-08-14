# frozen_string_literal: true

module V1
  class SchoolRelationshipSerializer < ApplicationSerializer
    attributes :name, :description, :role_list, :start_date, :end_date, :title

    belongs_to :school, id_method_name: :external_identifier
    belongs_to :person, id_method_name: :external_identifier
  end
end
