# frozen_string_literal: true

class Person < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  has_many :experiences, dependent: :destroy
  has_many :schools, through: :experiences

  has_many :person_roles, dependent: :destroy
  has_many :roles, through: :person_roles
  has_many :person_skills, dependent: :destroy
  has_many :skills, through: :person_skills

  has_one :address, as: :addressable, dependent: :destroy
end
