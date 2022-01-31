class School::Relationship < ApplicationRecord
  TYPES = []

  belongs_to :school
  belongs_to :person
end
