# frozen_string_literal: true

module V1
  class SchoolSearchSerializer < ApplicationSerializer
    include V1::Locationable
    include V1::Imageable

    attributes :name, :location, :charter_string

    # done this way to avoid n+1 queries
    attribute :ages_served_list do |person|
      person.taggings.select { |tagging| tagging.context == 'ages_served' }.map { |tagging| tagging.tag.name }
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
  end
end
