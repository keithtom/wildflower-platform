# frozen_string_literal: true

class Person < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  acts_as_taggable_on :audiences, :roles, :categories

  has_many :school_relationships, class_name: 'School::Relationship', dependent: :destroy
  has_many :schools, through: :school_relationships

  has_one :address, as: :addressable, dependent: :destroy
end
