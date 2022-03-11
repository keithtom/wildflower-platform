# frozen_string_literal: true

class Person < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  searchkick callbacks: :async

  acts_as_taggable_on :audiences, :roles

  has_many :school_relationships, dependent: :destroy
  has_many :schools, through: :school_relationships

  has_one :address, as: :addressable, dependent: :destroy
end
