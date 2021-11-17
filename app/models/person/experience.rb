# frozen_string_literal: true

module Person
  class Experience < ApplicationRecord
    belongs_to :person
    belongs_to :school, optional: true
  end
end
