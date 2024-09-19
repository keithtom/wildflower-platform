# frozen_string_literal: true

module V1
  class SchoolSerializer < ApplicationSerializer
    attributes :name, :short_name, :website, :phone, :email, :governance_type, :calendar,
               :max_enrollment, :facebook, :instagram, :status, :timezone, :domain,
               :hero_image2_url, :about, :about_es,
               :affiliation_date, :closed_on, :num_classrooms, :charter_string,
               :opened_on, :updated_at,
               :facility_type

    # done this way to avoid n+1 queries
    attribute :tuition_assistance_type_list do |person|
      person.taggings.select do |tagging|
        tagging.context == 'tuition_assistance_types'
      end.map { |tagging| tagging.tag.name }
    end

    # done this way to avoid n+1 queries
    attribute :ages_served_list do |person|
      person.taggings.select { |tagging| tagging.context == 'ages_served' }.map { |tagging| tagging.tag.name }
    end

    belongs_to :pod, id_method_name: :external_identifier do |school|
      school.pod
    end

    has_many :school_relationships, serializer: V1::SchoolRelationshipSerializer,
                                    id_method_name: :external_identifier do |school|
      school.school_relationships
    end

    has_many :people, id_method_name: :external_identifier do |school|
      school.people
    end

    has_many :sister_schools, id_method_name: :external_identifier do |school|
      school.sister_schools
    end

    has_one :address, serializer: V1::AddressSerializer, id_method_name: :external_identifier do |school|
      school.address
    end

    attribute :location do |school|
      if school.address
        if school.address.city.present? && school.address.state.present?
          "#{school.address.city}, #{school.address.state}"
        elsif school.address.city.blank? && school.address.state.present?
          "#{school.address.state}"
        elsif school.address.city.present?
          "#{school.address.city}"
        end
      elsif school.hub.present?
        school.hub.name
      end
    end

    attribute :hero_image_url do |school|
      if school.banner_image.attached?
        Rails.application.routes.url_helpers.rails_blob_url(school.banner_image)
      elsif school.hero_image_url.present?
        school.hero_image_url
      end
    end

    attribute :logo_url do |school|
      if school.logo_image.attached?
        Rails.application.routes.url_helpers.rails_blob_url(school.logo_image)
      elsif school.logo_url.present?
        school.logo_url
      end
    end
  end
end
