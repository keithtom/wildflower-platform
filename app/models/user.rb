# frozen_string_literal: true

class User < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  # Include default devise modules. Others available are:
  # :timeoutable
  devise :database_authenticatable, :rememberable, :trackable, :lockable
  # :registerable, :confirmable, :recoverable, :validatable,

  belongs_to :person, optional: true

  def password_required?
    false
  end

  def name
    "#{first_name} #{last_name}".strip if first_name
  end
end
