class Charter < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  acts_as_paranoid
  audited 

  has_many :schools
end