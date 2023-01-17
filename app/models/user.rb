# frozen_string_literal: true

class User < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
  :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

  belongs_to :person, optional: true

  def password_required?
    false
  end

  def name
    "#{first_name} #{last_name}".strip if first_name
  end

  # use external identifier in JWT, intead of the default id
  def self.find_for_jwt_authentication(sub)
    find_by!(external_identifier: sub)
  end

  def jwt_subject
    external_identifier
  end
end
