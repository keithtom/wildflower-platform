# frozen_string_literal: true

class Person
  class Role < ApplicationRecord
    belongs_to :person
    belongs_to :role
  end
end
