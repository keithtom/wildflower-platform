# frozen_string_literal: true

class Person
  class Skill
    belongs_to :person
    belongs_to :skill
  end
end
