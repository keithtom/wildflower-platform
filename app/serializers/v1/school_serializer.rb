# frozen_string_literal: true

module V1
  class SchoolSerializer < ApplicationSerializer
    attributes :name, :short_name, :website, :phone, :email, :governance_type, :tuition_assistance_type_list, :ages_served_list, :calendar,
               :max_enrollment, :facebook, :instagram, :status, :timezone, :domain, :logo_url, :raw_address, :opened_on, :updated_at

    belongs_to :pod

    has_many :school_relationships, serializer: V1::SchoolRelationshipSerializer
    has_many :people

    has_one :address
  end
end
