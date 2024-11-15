# frozen_string_literal: true

module V1
  class PersonSearchSerializer < PersonBasicSerializer
    attributes :email, :first_name, :middle_name, :last_name, :phone, :is_og?, :is_rgl?,
               :role_list,
               :show_ssj,
               :updated_at,
               :is_onboarded,
               :preferred_language

    attribute :show_network do |_person|
      nil
    end

    attribute :ssj_phase do |_person|
      nil
    end

    has_one :address, id_method_name: :external_identifier do |_person|
      nil
    end

    # done this way to avoid n+1 queries
    attribute :montessori_certified_level_list do |person|
      person.taggings.select do |tagging|
        tagging.context == 'montessori_certified_levels'
      end.map { |tagging| tagging.tag.name }
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
      end
    end
  end
end
