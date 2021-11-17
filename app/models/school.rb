# frozen_string_literal: true

class School < ApplicationRecord
  has_one :address, as: :addressable

  # has_one ops_guide, # person , scoped to role...
end
