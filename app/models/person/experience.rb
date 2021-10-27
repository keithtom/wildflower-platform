class Person::Experience < ApplicationRecord
  belongs_to :person
  belongs_to :school, optional: true
end
