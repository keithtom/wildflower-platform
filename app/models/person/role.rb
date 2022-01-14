# frozen_string_literal: true

# A join table of Person and Role
class Person
  class Role < ApplicationRecord
    self.table_name = "person_roles"

    belongs_to :person
    belongs_to :role
  end
end
