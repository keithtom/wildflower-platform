class Person < ApplicationRecord
  has_many :roles
  has_many :skills
  has_many :experiences
  has_many :schools, through: :experiences

  has_one :address, as: :addressable
end
