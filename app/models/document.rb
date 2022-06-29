class Document < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  belongs_to :documentable, polymorphic: true
end
