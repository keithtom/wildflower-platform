# frozen_string_literal: true

module V1
  class PeopleSerializer < ApplicationSerializer
    attributes :email, :first_name, :last_name, :phone
  end
end
