# frozen_string_literal: true

module V1
  class PersonCardSerializer < ApplicationSerializer
    include V1::Imageable

    attributes :email, :first_name, :last_name, :phone

    attribute :image_url do |person|
      image_url(person)
    end
  end
end
