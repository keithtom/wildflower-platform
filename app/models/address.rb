# frozen_string_literal: true

class Address < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  audited

  belongs_to :addressable, polymorphic: true, optional: true, touch: true

  after_commit :reindex_addressable

  def full_address
    total = ""

    if line1
      total += line1
    end

    if line2
      unless total.empty?
        total += ", "
      end
      total += line2
    end

    if city
      unless total.empty?
        total += ", "
      end
      total += city
    end

    if state
      unless total.empty?
        total += ", "
      end
      total += state
    end

    if zip
      unless total.empty?
        total += " "
      end
      total += zip
    end
  
    return total
  end

  private

  # https://github.com/ankane/searchkick#indexing
  def reindex_addressable
    addressable.try(:reindex)
  end
end
