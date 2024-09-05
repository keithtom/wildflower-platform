# frozen_string_literal: true

class OpenTlMailer < ApplicationMailer
  default bcc: 'support@wildflowerschools.org'

  def invite(user_id)
    @user = User.find(user_id)
    mail to: @user.email, cc: 'support@wildflowerschools.org',
         subject: '*Correction* Monthly Admin Checklists now on My Wildflower'
  end

  def invite_partner(user_id, inviter_id)
    @user = User.find(user_id)
    @inviter = User.find(inviter_id)
    @invite_url = "#{ENV.fetch('FRONTEND_URL', nil)}/token?token=#{@user.authentication_token}"
    mail to: @user.email, cc: 'support@wildflowerschools.org', subject: 'Welcome to My Wildflower'
  end
end
