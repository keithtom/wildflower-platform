# frozen_string_literal: true

class Person
  class Experience < ApplicationRecord
    belongs_to :person
    belongs_to :school, optional: true
  end
end
