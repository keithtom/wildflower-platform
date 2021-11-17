# frozen_string_literal: true

module V1
  class AddressSerializer < ApplicationSerializer
    attributes :line1, :line2, :city, :state, :zip, :country
  end
end
