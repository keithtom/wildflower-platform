class Pod < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  belongs_to :hub
  belongs_to :primary_contact, class_name: 'Person', optional: true

  has_many :schools
  has_many :people
end
