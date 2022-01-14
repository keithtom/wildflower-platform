# frozen_string_literal: true

# Represents an experience by a person.  Also joins to schools.
class Person
  class Experience < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    belongs_to :person
    belongs_to :school, optional: true
  end
end
