# frozen_string_literal: true

module V1
  class SchoolSerializer < ApplicationSerializer
    attributes :name, :short_name, :website, :phone, :email, :governance_type, :calendar,
               :max_enrollment, :facebook, :instagram, :status, :timezone, :domain,
               :logo_url, :hero_image_url, :hero_image2_url, :about, :about_es,
               :affiliation_date, :closed_on, :num_classrooms, :charter_string,
               :opened_on, :updated_at,
               :facility_type

    # done this way to avoid n+1 queries
    attribute :tuition_assistance_type_list do |person|
      person.taggings.select { |tagging| tagging.context == "tuition_assistance_types" }.map { |tagging| tagging.tag.name }
    end

    # done this way to avoid n+1 queries
    attribute :ages_served_list do |person|
      person.taggings.select { |tagging| tagging.context == "ages_served" }.map { |tagging| tagging.tag.name }
    end

    belongs_to :pod, id_method_name: :external_identifier do |school|
      school.pod
    end

    has_many :school_relationships, id_method_name: :external_identifier do |school|
      school.school_relationships
    end

    has_many :people, id_method_name: :external_identifier do |school|
      school.people
    end

    has_one :address, serializer: V1::AddressSerializer, id_method_name: :external_identifier do |school|
      school.address
    end
  
    attribute :hero_image_url do |school|
      if school.banner_image.attached?
        Rails.application.routes.url_helpers.rails_blob_url(school.banner_image)
      elsif school.hero_image_url.present?
        school.hero_image_url
      end
    end
  end
end
