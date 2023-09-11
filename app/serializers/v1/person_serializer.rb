# frozen_string_literal: true

module V1
  class PersonSerializer < ApplicationSerializer
    attributes :email, :first_name, :middle_name, :last_name, :phone, :journey_state,
      :personal_email, :about, :primary_language, :updated_at, :race_ethnicity_other, :lgbtqia, :gender, :pronouns, :household_income, 
      :primary_language_other, :gender_other, :pronouns_other, :montessori_certified,
      :start_date, :end_date, :active, :is_onboarded


    # done this way to avoid n+1 queries
    attribute :role_list do |person|
      person.taggings.select { |tagging| tagging.context == "roles" }.map { |tagging| tagging.tag.name }
    end

    # done this way to avoid n+1 queries
    attribute :race_ethnicity_list do |person|
      person.taggings.select { |tagging| tagging.context == "race_ethnicity" }.map { |tagging| tagging.tag.name }
    end

    # done this way to avoid n+1 queries
    attribute :montessori_certified_level_list do |person|
      person.taggings.select { |tagging| tagging.context == "montessori_certified_levels" }.map { |tagging| tagging.tag.name }
    end

    # done this way to avoid n+1 queries
    attribute :classroom_age_list do |person|
      person.taggings.select { |tagging| tagging.context == "classroom_age" }.map { |tagging| tagging.tag.name }
    end

    attribute :location do |person|
      if person.address
        if person.address.city.present? && person.address.state.present?
          "#{person.address.city}, #{person.address.state}"
        elsif person.address.city.blank? && person.address.state.present?
          "#{person.address.state}"
        elsif person.address.city.present?
          "#{person.address.city}"
        end
      else
        if person.hub.present?
          person.hub.name
        else
          nil
        end
      end
    end
    
    has_many :schools, id_method_name: :external_identifier do |person|
      person.schools
    end

    # consider not serializing this for privacy reasons.  how does front-end use it?
    has_one :address, id_method_name: :external_identifier do |person|
      person.address
    end

    attribute :image_url do |person|
      if person.profile_image.attached?
        Rails.application.routes.url_helpers.rails_blob_url(person.profile_image)
      elsif person.image_url.present?
        person.image_url
      end
    end
  end
end
