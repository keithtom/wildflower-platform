# frozen_string_literal: true

module V1
  class PersonBasicSerializer < ApplicationSerializer
    include V1::Imageable

    attributes :email, :first_name, :middle_name, :last_name, :phone, :is_og?, :is_rgl?,
               :role_list,
               :show_ssj,
               :updated_at,
               :is_onboarded,
               :preferred_language,
               :active, :end_date

    attribute :image_url do |person|
      image_url(person)
    end

    attribute :show_network do |person|
      person.role_list.include?(PeopleRelationship::FOUNDATION_PARTNER) || person.affiliated_at.present?
    end

    # has_many :schools, id_method_name: :external_identifier do |person|
    #   person.schools
    # end

    attribute :ssj_phase do |person|
      person.schools.first&.workflows&.first&.current_phase
    end

    has_one :address, id_method_name: :external_identifier do |person|
      person.address
    end
  end
end
