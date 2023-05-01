# frozen_string_literal: true

module V1
  class PersonSerializer < ApplicationSerializer
    attributes :email, :first_name, :middle_name, :last_name, :phone, :journey_state,
      :personal_email, :about, :primary_language, :updated_at, :race_ethnicity_other, :lgbtqia, :gender, :pronouns, :household_income, 
      :primary_language_other, :race_ethnicity_list, :gender_other, :pronouns_other, :montessori_certified, :montessori_certified_levels, :classroom_age

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

    attribute :image_url do |person|
      if person.profile_image.attached?
        Rails.application.routes.url_helpers.rails_blob_path(person.profile_image, only_path: true)
      elsif person.image_url.present?
        person.image_url
      end
    end
  end
end
