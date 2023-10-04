class Charter < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  audited 

  has_many :schools
end