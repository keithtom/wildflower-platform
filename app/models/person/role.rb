class Person::Role < ApplicationRecord
  belongs_to :person

  ASSISTANT = 'assistant'.freeze
  FOUNDER = 'founder'.freeze
  TEACHER = 'teacher'.freeze
  OPS_GUIDE = 'operations guide'.freeze
  FOUNDATION = 'foundation partner'.freeze
  BOARD_MEMBER = 'board member'.freeze
  ROLES = [ASSISTANT, FOUNDER, TEACHER, OPS_GUIDE, FOUNDATION].freeze
end
