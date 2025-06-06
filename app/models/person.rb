# frozen_string_literal: true

require 'airtable/platform'

class Person < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  acts_as_paranoid
  audited

  ROLES = [OPS_GUIDE = 'Ops Guide', RGL = 'Regional Entrepreneur', ETL = 'Emerging Teacher Leader',
           TL = 'Teacher Leader', BOARD_MEMBER = 'Board Member']

  searchkick callbacks: :async, word_middle: %i[name schools about montessori_certified_levels],
             text_middle: %i[languages race_ethnicities roles genders]
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
  # Allows update of address via person without passing in an id. We currently don't create a user w/ an address, so this is fine.
  accepts_nested_attributes_for :address, update_only: true

  has_many :decisions, class_name: 'Advice::Decision', foreign_key: :creator_id

  has_many :assignments, class_name: 'Workflow::Instance::StepAssignment', foreign_key: :assignee_id

  # https://github.com/ankane/searchkick#indexing
  scope :search_import, -> { includes([:school_relationships, :schools, :address, { taggings: :tag }]) }

  attr_accessor :full_name

  before_validation :set_name, if: proc { |person| person.full_name.present? }
  before_validation :normalize_email

  has_one :user, dependent: :nullify
  after_update :sync_user_email, if: :saved_change_to_email?

  has_one_attached :profile_image

  validates :email, uniqueness: true, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be a valid email address' }

  before_destroy :remove_from_airtable

  # https://github.com/ankane/searchkick#indexing
  def search_data
    {
      # general free text search, ordered by general relevance
      name:,
      schools: schools.map(&:name).join(' '),
      about:, # limit memory usage...?
      roles: role_list,
      tl_roles: tl_role_list.join(' '),
      race_ethnicities: race_ethnicity_list.add(race_ethnicity_other),
      primary_language:,
      languages: language_list.add(primary_language),
      montessori_certified_levels: montessori_certified_level_list.join(' '),
      hub: hub&.name,
      pod: pod&.name,
      address_city: address&.city,
      email:,
      classroom_age: classroom_age_list.join(' '),
      foundation_roles: foundation_role_list.join(' '),
      rse_roles: rse_role_list.join(' '),
      og_roles: og_role_list.join(' '),
      genders: [gender, gender_other],
      address_state: address&.state,
      is_onboarded:,
      active:
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

  def is_og?
    role_list.include?(OPS_GUIDE)
  end

  def is_rgl?
    role_list.include?(RGL)
  end

  private

  def set_name
    names = full_name.split
    self.first_name = names.first
    self.last_name = names.last
    self.middle_name = names[1] if names.length == 3
  end

  def normalize_email
    self.email = email.to_s.strip.downcase if email.present?
  end

  def remove_from_airtable
    RemoveAirtableRecordJob.perform_later(platform_airtable_id, Airtable::Platform::PEOPLE) if platform_airtable_id
  end

  def sync_user_email
    user.update(email:) if user.present?
  end
end
