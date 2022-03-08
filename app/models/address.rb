# frozen_string_literal: true

class Address < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  belongs_to :addressable, polymorphic: true, optional: true
end
