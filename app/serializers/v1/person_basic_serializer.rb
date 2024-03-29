# frozen_string_literal: true

module V1
  class PersonBasicSerializer < ApplicationSerializer
    attributes :email, :first_name, :middle_name, :last_name, :phone, :is_og?, :is_rgl?,
               :role_list,
               :show_ssj,
               :updated_at,
               :is_onboarded
    
    attribute :image_url do |person|
      if person.profile_image.attached?
        Rails.application.routes.url_helpers.rails_blob_url(person.profile_image)
      elsif person.image_url.present?
        person.image_url
      end
    end
  
    attribute :show_network do |person|
      person.role_list.include?(PeopleRelationship::FOUNDATION_PARTNER) || person.affiliated_at.present?
    end

    # has_many :schools, id_method_name: :external_identifier do |person|
    #   person.schools
    # end

    attribute :ssj_phase do |person|
      if person.ssj_team
        person.ssj_team&.workflow&.current_phase
      end
    end

    has_one :address, id_method_name: :external_identifier do |person|
      person.address
    end
  end

end
