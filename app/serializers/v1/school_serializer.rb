# frozen_string_literal: true

module V1
  class SchoolSerializer < ApplicationSerializer
    attributes :name, :short_name, :website, :phone, :email, :governance_type, :tuition_assistance_type_list, :ages_served_list, :calendar,
               :max_enrollment, :facebook, :instagram, :status, :timezone, :domain, :logo_url, :opened_on, :updated_at

    belongs_to :pod, id_method_name: :external_identifier do |school|
      school.pod
    end
    has_many :school_relationships, id_method_name: :external_identifier do |school|
      school.school_relationships.includes([:person])
    end
    has_many :people, id_method_name: :external_identifier do |school|
      school.people
    end
    has_one :address, id_method_name: :external_identifier do |school|
      school.address
    end
  end
end
