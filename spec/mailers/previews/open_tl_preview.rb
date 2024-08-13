# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers
class OpenTlPreview < ActionMailer::Preview
  def invite
    OpenTlMailer.invite(User.first.id)
  end
end
