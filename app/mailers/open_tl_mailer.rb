# frozen_string_literal: true

class OpenTlMailer < ApplicationMailer
  default bcc: 'support@wildflowerschools.org'

  def invite(user_id)
    @user = User.find(user_id)
    mail to: @user.email, cc: 'support@wildflowerschools.org',
         subject: 'Monthly Admin Checklists now on My Wildflower'
    # TODO: subject needs to be updated to be generalized
  end

  def invite_partner(user_id, inviter_id, school_name)
    @user = User.find(user_id)
    @inviter = User.find(inviter_id)
    @school_name = school_name
    @invite_url = "#{ENV.fetch('FRONTEND_URL', nil)}/token?token=#{@user.authentication_token}"
    mail to: @user.email, cc: ['support@wildflowerschools.org', @inviter.email],
         subject: 'Welcome to My Wildflower – Log in to activate your account!'
  end
end
