# frozen_string_literal: true

class Person < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  searchkick # callbacks: :async

  acts_as_taggable_on :audiences, :roles, :languages, :race_ethnicity

  belongs_to :hub, optional: true
  belongs_to :pod, optional: true

  has_many :people_relationships
  # has_one :foundation_partner, through: :school_relationships, -> { where(kind: PeopleRelationship::FOUNDATION_PARTNER) }
  has_many :other_people

  has_many :school_relationships
  has_many :schools, through: :school_relationships

  has_one :address, as: :addressable

  # https://github.com/ankane/searchkick#indexing
  scope :search_import, -> { includes([:school_relationships, :schools, :address, {:taggings => :tag}]) }

  # https://github.com/ankane/searchkick#indexing
  def search_data
    {
      hub: hub.name,
      pod: pod.name,
      email: email,
      personal_email: personal_email,
      name: "#{first_name} #{middle_name} #{last_name}",
      audiences: audience_list.join(" "),
      roles: role_list.join(" "),
      address_city: address&.city,
      address_state: address&.state,
      about: about.truncate(500),
    }
  end
end
