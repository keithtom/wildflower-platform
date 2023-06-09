# frozen_string_literal: true

class Person < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  searchkick callbacks: :async
  include Person::Workflow
  include Person::SSJ

  acts_as_taggable_on :roles, :tl_roles, :foundation_roles, :rse_roles, :og_roles,
    :languages,
    :race_ethnicity,
    :montessori_certified_levels,
    :classroom_age

  belongs_to :hub, optional: true
  belongs_to :pod, optional: true

  has_many :people_relationships
  # has_one :foundation_partner, through: :school_relationships, -> { where(kind: PeopleRelationship::FOUNDATION_PARTNER) }
  has_many :other_people

  # current _school
  has_many :school_relationships
  has_many :schools, through: :school_relationships

  has_one :address, as: :addressable
  accepts_nested_attributes_for :address

  has_many :decisions, class_name: "Advice::Decision", foreign_key: :creator_id

  # https://github.com/ankane/searchkick#indexing
  scope :search_import, -> { includes([:school_relationships, :schools, :address, {:taggings => :tag}]) }

  attr_accessor :full_name
  before_validation :set_name, if: Proc.new { |person| person.full_name.present? }

  has_one_attached :profile_image

  # https://github.com/ankane/searchkick#indexing
  def search_data
    {
      # general free text search
      hub: hub&.name,
      pod: pod&.name,
      name: name,
      about: about&.truncate(5000), # limit memory usage...?
      address_city: address&.city,
      email: email,
      # school name?
      # filters below
      primary_language: primary_language,
      roles: role_list.join(" "),
      gender: [gender, gender_other].join(" "),
      race_ethnicity: race_ethnicity_list.add(race_ethnicity_other).join(" "),
      address_state: address&.state,
    }
  end

  def subroles
    # for person, need to iterate over TL roles, foundation roles etc.
    # RSE = regional site entrepreneur, OG = operations guide
    tl_role_list + foundation_role_list + rse_role_list + og_role_list
  end

  def name
    "#{first_name} #{middle_name} #{last_name}"
  end

  private

  def set_name
    names = full_name.split
    self.first_name = names.first
    self.last_name = names.last
    if names.length == 3
      self.middle_name = names[1]
    end
  end
end
