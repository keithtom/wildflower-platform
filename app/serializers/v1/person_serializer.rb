# frozen_string_literal: true

module V1
  class PersonSerializer < ApplicationSerializer
    attributes :email, :first_name, :last_name, :phone

    has_many :schools
    has_many :roles
    has_many :skills
    has_many :experiences, :serializer => V1::Person::ExperienceSerializer

    has_one :address
  end
end
