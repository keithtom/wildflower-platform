# frozen_string_literal: true

module V1
  module Person
    class ExperienceSerializer < ApplicationSerializer
      attributes :name, :description, :start_date, :end_date
    end
  end
end
