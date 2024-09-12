class NetworkMailer < ApplicationMailer
  default bcc: 'support@wildflowerschools.org'

  def invite(user)
    @user = user

    @invite_url = "#{ENV.fetch('FRONTEND_URL', nil)}/token?token=#{user.authentication_token}"

    mail to: @user.email, subject: "Welcome to #{ENV.fetch('APP_NAME', nil)}!"
  end

  def remind_login(user)
    @user = user

    @invite_url = "#{ENV.fetch('FRONTEND_URL', nil)}/token?token=#{user.authentication_token}"

    mail to: @user.email,
         subject: "5 min request: Vote on the next #{ENV.fetch('APP_NAME', nil)} features we should build!"
  end

  def remind_login2(user_id)
    @user = User.find(user_id)
    school = @user.person.schools&.first
    @profile_url = "#{ENV.fetch('FRONTEND_URL', nil)}/network/people/#{@user.person.external_identifier}"
    @school_profile_url = "#{ENV.fetch('FRONTEND_URL', nil)}/network/schools/#{school.external_identifier}" if school
    mail to: @user.email, cc: 'support@wildflowerschools.org',
         subject: '**Update Your Profile on the Network Directory**'
  end
end
