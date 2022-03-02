# frozen_string_literal: true

module V1
  class SchoolSerializer < ApplicationSerializer
    attributes :name, :short_name, :website, :phone, :email, :governance_type, :tuition_assistance_type, :ages_served, :calendar,
               :max_enrollment, :facebook, :instagram

    belongs_to :pod
    has_one :address

    has_many :people
  end
end
