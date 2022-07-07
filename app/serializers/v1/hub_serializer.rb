# frozen_string_literal: true

module V1
  class HubSerializer < ApplicationSerializer
    attributes :name

    belongs_to :entrepreneur, serializer: V1::PersonSerializer, id_method_name: :external_identifier do |hub|
      hub.entrepreneur
    end
  end
end
