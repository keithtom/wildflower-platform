# frozen_string_literal: true

class Role < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  ASSISTANT = 'assistant'
  FOUNDER = 'founder'
  TEACHER = 'teacher'
  OPS_GUIDE = 'operations guide'
  FOUNDATION = 'foundation partner'
  BOARD_MEMBER = 'board member'
  ROLES = [ASSISTANT, FOUNDER, TEACHER, OPS_GUIDE, FOUNDATION].freeze
end
