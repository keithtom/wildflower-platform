class SchoolRelationship < ApplicationRecord
  TYPES = []

  belongs_to :school
  belongs_to :person
end
