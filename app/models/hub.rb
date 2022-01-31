class Hub < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  belongs_to :entrepreneur, class_name: 'Person'
end
