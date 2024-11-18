# frozen_string_literal: true

module V1
  class PersonSearchSerializer < ApplicationSerializer
    include V1::Imageable
    include V1::Locationable

    attributes :email, :first_name, :last_name

    attribute :image_url do |person|
      image_url(person)
    end

    # done this way to avoid n+1 queries
    attribute :role_list do |person|
      person.taggings.select { |tagging| tagging.context == 'roles' }.map { |tagging| tagging.tag.name }
    end

    # done this way to avoid n+1 queries
    attribute :montessori_certified_level_list do |person|
      person.taggings.select do |tagging|
        tagging.context == 'montessori_certified_levels'
      end.map { |tagging| tagging.tag.name }
    end

    attribute :location do |person|
      location(person)
    end
  end
end
