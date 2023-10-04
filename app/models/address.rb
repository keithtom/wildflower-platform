# frozen_string_literal: true

class Address < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  audited

  belongs_to :addressable, polymorphic: true, optional: true, touch: true

  after_commit :reindex_addressable

  private

  # https://github.com/ankane/searchkick#indexing
  def reindex_addressable
    addressable.try(:reindex)
  end
end
