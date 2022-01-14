# frozen_string_literal: true

# A join table of Person and Skill
class Person
  class Skill < ApplicationRecord
    self.table_name = "person_skills"

    belongs_to :person
    belongs_to :skill
  end
end
