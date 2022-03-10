# frozen_string_literal: true

class School < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  acts_as_taggable_on :audiences

  belongs_to :pod, optional: true
  has_one :address, as: :addressable, dependent: :destroy, required: false, inverse_of: :addressable

  has_many :school_relationships, dependent: :destroy
  has_many :people, through: :school_relationships

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
end
