# frozen_string_literal: true

module V1
  class PodSerializer < ApplicationSerializer
    attributes :name

    belongs_to :hub, id_method_name: :external_identifier do |pod|
      pod.hub
    end
    belongs_to :primary_contact, serializer: V1::PersonSerializer, id_method_name: :external_identifier do |pod|
      pod.primary_contact
    end
  end
end
