module V1
  class UserSerializer < ApplicationSerializer
    attributes :email

    attribute :first_name do |user|
      unless user.person.nil?
        user.person.first_name
      end
    end

    attribute :last_name do |user|
      unless user.person.nil?
        user.person.last_name
      end
    end

    attribute :image_url do |user|
      unless user.person.nil?
        user.person.image_url
      end
    end

    belongs_to :person, serializer: V1::PersonSerializer, id_method_name: :external_identifier do |user|
      user.person
    end
  end
end
