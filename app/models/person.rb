# frozen_string_literal: true

class Person < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  searchkick callbacks: :async

  acts_as_taggable_on :audiences, :roles

  has_many :school_relationships
  has_many :schools, through: :school_relationships

  has_one :address, as: :addressable

  # https://github.com/ankane/searchkick#indexing
  scope :search_import, -> { includes([:school_relationships, :schools, :address, {:taggings => :tag}]) }

  # https://github.com/ankane/searchkick#indexing
  def search_data
    {
      email: email,
      name: "#{first_name} #{last_name}",
      audiences: audience_list.join(" "),
      roles: role_list.join(" "),
      address_city: address&.city,
      address_state: address&.state
    }
  end
end
