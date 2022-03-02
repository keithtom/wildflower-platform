# frozen_string_literal: true

module V1
  class PodSerializer < ApplicationSerializer
    attributes :name

    belongs_to :hub
    belongs_to :primary_contact, serializer: V1::PersonSerializer, id_methodname: :external_identifier
  end
end
