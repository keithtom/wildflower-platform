class Hub < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  acts_as_paranoid

  belongs_to :entrepreneur, class_name: 'Person', optional: true

  has_many :pods
  has_many :schools
  has_many :people
end
