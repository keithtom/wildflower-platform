# frozen_string_literal: true

module V1
  class PersonSerializer < ApplicationSerializer
    attributes :email, :first_name, :middle_name, :last_name, :phone, :journey_state,
      :personal_email, :about, :primary_language, :updated_at

    has_many :schools
    has_many :school_relationships, serializer: V1::SchoolRelationshipSerializer

    attribute :role_list
    # has_many :roles, serializer: V1::TagSerializer
    # has_many :audiences, serializer: V1::TagSerializer

    has_one :address
  end
end
