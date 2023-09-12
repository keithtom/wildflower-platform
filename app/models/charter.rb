class Charter < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier
  has_many :schools
end