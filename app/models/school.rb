# frozen_string_literal: true

class School < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  acts_as_taggable_on :ages_served, :tuition_assistance_types, :previous_names

  searchkick callbacks: :async, text_middle: [:age_levels, :address_state]

  belongs_to :hub, optional: true
  belongs_to :pod, optional: true
  belongs_to :charter, optional: true
  has_many :sister_schools, through: :charter, source: :schools
  has_one :address, as: :addressable, required: false, inverse_of: :addressable
  accepts_nested_attributes_for :address

  has_many :school_relationships
  has_many :people, through: :school_relationships
  accepts_nested_attributes_for :school_relationships

  has_one_attached :banner_image
  has_one_attached :logo_image

  module Governance
    CHARTER = 'Charter'
    INDEPENDENT = 'Independent'
    DISTRICT = 'District'
    TYPES = [CHARTER, INDEPENDENT, DISTRICT]
  end

  module TuitionAssistance
    STATE_VOUCHERS = 'State vouchers'
    COUNTY_ASSISTANCE = 'County Childcare Assistance Programs'
    CITY_VOUCHERS = 'City vouchers'
    SCHOOL_ASSISTANCE = 'School-supported scholarship and/or tuition discount program'
    PRIVATE_DONOR_ASSISTANCE = 'Private-donor funded scholarship program'
    TYPES = [STATE_VOUCHERS, COUNTY_ASSISTANCE, CITY_VOUCHERS]
  end

  module AgesServed
    PARENT_CHILD = 'Parent child'
    INFANTS = 'Infants'
    TODDLERS = 'Toddlers'
    PRIMARY = 'Primary'
    LOWER_ELEMENTARY = 'Lower Elementary'
    UPPER_ELEMENTARY = 'Upper Elementary'
    ADOLESCENT = 'Adolescent'
    HIGH_SCHOOL = 'High School'
    TYPES = [PARENT_CHILD, INFANTS, TODDLERS, PRIMARY, LOWER_ELEMENTARY, UPPER_ELEMENTARY, ADOLESCENT, HIGH_SCHOOL]
  end

  module Calendar
    NINE_MONTH = '9 month'
    TEN_MONTH = '10 month'
    YEAR_ROUND = 'Year Round'
    TYPES = [NINE_MONTH, TEN_MONTH, YEAR_ROUND]
  end

  # https://github.com/ankane/searchkick#indexing
  scope :search_import, -> { includes([:school_relationships, :people, :address, {:taggings => :tag}]) }

  # https://github.com/ankane/searchkick#indexing
  def search_data
    {
      name: name,
      short_name: short_name,
      previous_names: previous_name_list.join(" "),
      website: website,
      email: email,
      phone: phone,
      domain: domain,
      governance_type: governance_type,
      age_levels: ages_served_list,
      tuition_assistance_types: tuition_assistance_type_list.join(" "),
      address_city: address&.city,
      address_state: address&.state,
      about: about, # limit memory usage...?
      facility_type: facility_type,
      charter: charter_string,
      open_date: opened_on&.to_datetime,
      affiliated: affiliated
    }
  end
end
