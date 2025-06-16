# frozen_string_literal: true

module V1
  class SchoolSerializer < ApplicationSerializer
    include V1::Locationable
    include V1::Imageable

    attributes :name, :short_name, :website, :phone, :email, :governance_type, :calendar,
               :max_enrollment, :facebook, :instagram, :status, :timezone, :domain,
               :hero_image2_url, :about, :about_es,
               :affiliation_date, :affiliated, :closed_on, :num_classrooms, :charter_string,
               :opened_on, :updated_at, :expected_start_date,
               :facility_type, :directory_visible

    # done this way to avoid n+1 queries
    attribute :tuition_assistance_type_list do |person|
      person.taggings.includes([:tag]).select do |tagging|
        tagging.context == 'tuition_assistance_types'
      end.map { |tagging| tagging.tag.name }
    end

    # done this way to avoid n+1 queries
    attribute :ages_served_list do |person|
      person.taggings.select { |tagging| tagging.context == 'ages_served' }.map { |tagging| tagging.tag.name }
    end

    # belongs_to :pod, id_method_name: :external_identifier do |school|
    #   school.pod
    # end

    has_many :school_relationships, serializer: V1::SchoolRelationshipSerializer,
                                    id_method_name: :external_identifier do |school|
      school.school_relationships
    end

    has_many :people, serializer: V1::PersonSerializer, id_method_name: :external_identifier do |school, params|
      school.people
    end

    has_many :sister_schools, id_method_name: :external_identifier do |school|
      school.sister_schools
    end

    has_one :address, serializer: V1::AddressSerializer, id_method_name: :external_identifier do |school|
      school.address
    end

    attribute :ops_guides do |school|
      school.ops_guides.map { |ops_guide| V1::PersonCardSerializer.new(ops_guide) }
    end

    attribute :rgls do |school|
      school.rgls.map { |rgl| V1::PersonCardSerializer.new(rgl) }
    end

    attribute :active_partners do |school|
      school.active_partners.map { |rgl| V1::PersonCardSerializer.new(rgl) }
    end

    attribute :invited_partners do |school|
      school.invited_partners.map { |rgl| V1::PersonCardSerializer.new(rgl) }
    end

    attribute :has_partner do |school|
      school.partner_count > 1
    end

    attribute :location do |school|
      location(school)
    end

    attribute :hero_image_url do |school|
      hero_image_url(school)
    end

    attribute :logo_url do |school|
      logo_url(school)
    end

    attribute :workflow_ids do |school|
      school.workflows.visible.pluck(:external_identifier)
    end

    # for SSJ only
    attribute :current_phase do |school|
      school.workflows.first&.current_phase
    end
  end
end
