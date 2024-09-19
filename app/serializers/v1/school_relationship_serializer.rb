# frozen_string_literal: true

module V1
  class SchoolRelationshipSerializer < ApplicationSerializer
    attributes :name, :description, :role_list, :start_date, :end_date, :title

    belongs_to :school, serializer: SchoolSerializer, id_method_name: :external_identifier do |sr|
      sr.school
    end
    belongs_to :person, serializer: PersonSerializer, id_method_name: :external_identifier do |sr, params|
      sr.person
    end
  end
end
