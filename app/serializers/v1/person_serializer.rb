# frozen_string_literal: true

module V1
  class PersonSerializer < ApplicationSerializer
    include V1::Imageable
    include V1::Locationable

    attributes :email, :first_name, :middle_name, :last_name, :phone, :journey_state, :preferred_language,
               :personal_email, :about, :primary_language, :updated_at, :race_ethnicity_other, :lgbtqia, :gender, :pronouns, :household_income,
               :primary_language_other, :gender_other, :pronouns_other, :montessori_certified, :montessori_certified_year,
               :start_date, :end_date, :active, :is_onboarded, :is_og?, :is_rgl?

    # done this way to avoid n+1 queries
    attribute :role_list do |person|
      person.taggings.select { |tagging| tagging.context == 'roles' }.map { |tagging| tagging.tag.name }
    end

    # done this way to avoid n+1 queries
    attribute :race_ethnicity_list do |person|
      person.taggings.select { |tagging| tagging.context == 'race_ethnicity' }.map { |tagging| tagging.tag.name }
    end

    # done this way to avoid n+1 queries
    attribute :montessori_certified_level_list do |person|
      person.taggings.select do |tagging|
        tagging.context == 'montessori_certified_levels'
      end.map { |tagging| tagging.tag.name }
    end

    # done this way to avoid n+1 queries
    attribute :classroom_age_list do |person|
      person.taggings.select { |tagging| tagging.context == 'classroom_age' }.map { |tagging| tagging.tag.name }
    end

    attribute :location do |person|
      location(person)
    end

    has_many :schools, id_method_name: :external_identifier do |person|
      person.schools
    end

    has_many :school_relationships, id_method_name: :external_identifier do |person|
      person.school_relationships
    end

    # consider not serializing this for privacy reasons.  how does front-end use it?
    has_one :address, id_method_name: :external_identifier do |person|
      person.address
    end

    attribute :image_url do |person|
      image_url(person)
    end
  end
end
