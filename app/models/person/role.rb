# frozen_string_literal: true

class Person
  class Role
    belongs_to :person
    belongs_to :role
  end
end
