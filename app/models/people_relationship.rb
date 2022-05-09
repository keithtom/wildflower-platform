class PeopleRelationship < ApplicationRecord
  FOUNDATION_PARTNER = 'foundation partner'
  SCHOOL_PARTNER = 'school partner'

  belongs_to :person
  belongs_to :other_person
end
