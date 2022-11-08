# frozen_string_literal: true

module V1
  class PersonSerializer < ApplicationSerializer
    attributes :email, :first_name, :middle_name, :last_name, :phone, :journey_state,
      :personal_email, :about, :primary_language, :updated_at, :image_url

    attribute :role_list
    # has_many :roles, serializer: V1::TagSerializer
    # has_many :audiences, serializer: V1::TagSerializer

    has_many :schools, id_method_name: :external_identifier do |person|
      person.schools
    end
    has_many :school_relationships, id_method_name: :external_identifier do |person|
      person.school_relationships
    end

    has_one :address, id_method_name: :external_identifier do |person|
      person.address
    end
  end
end
