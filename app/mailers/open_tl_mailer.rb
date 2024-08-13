# frozen_string_literal: true

class OpenTlMailer < ApplicationMailer
  default bcc: 'support@wildflowerschools.org'

  def invite(user_id)
    @user = User.find(user_id)
    mail to: @user.email, cc: 'support@wildflowerschools.org', subject: 'SUBJECT TBD'
  end
end
