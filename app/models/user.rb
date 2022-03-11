# frozen_string_literal: true

class User < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  belongs_to :person, optional: true

  def password_required?
    false
  end

  def name
    "#{first_name} #{last_name}".strip if first_name
  end
end
