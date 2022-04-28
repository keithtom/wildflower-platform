class Pod < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  belongs_to :hub
  belongs_to :primary_contact, class_name: 'Person', optional: true
end
