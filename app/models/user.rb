# frozen_string_literal: true

class User < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :token_authenticatable,
  :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

  belongs_to :person, optional: true

  def password_required?
    false
  end

  def name
    "#{person.first_name} #{person.last_name}".strip if person
  end

  # use external identifier in JWT, intead of the default id
  def self.find_for_jwt_authentication(sub)
    find_by!(external_identifier: sub)
  end

  def jwt_subject
    external_identifier
  end

  # burn token after authentication
  def after_token_authentication
    # TODO: comment back in before merging
    # self.authentication_token = nil
    # self.authentication_token_created_at = nil
    # self.save!
  end

  def valid_password?(password)
    if password.blank? && !password_required?
      true
    else
       Devise::Encryptor.compare(self.class, encrypted_password, password)
    end
  end
end

