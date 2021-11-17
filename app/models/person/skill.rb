# frozen_string_literal: true

module Person
  class Skill < ApplicationRecord
    belongs_to :person
  end
end
