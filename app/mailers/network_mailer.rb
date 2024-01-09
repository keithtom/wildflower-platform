class NetworkMailer < ApplicationMailer
  default bcc: "support@wildflowerschools.org"

  def invite(user)
    @user = user
    
    @invite_url = "#{ENV['FRONTEND_URL']}/token?token=#{user.authentication_token}"

    mail to: @user.email, subject: "Welcome to #{ENV['APP_NAME']}!"
  end

  def remind_login(user)
    @user = user
    
    @invite_url = "#{ENV['FRONTEND_URL']}/token?token=#{user.authentication_token}"

    mail to: @user.email, subject: "5 min request: Vote on the next #{ENV['APP_NAME']} features we should build!"
  end
end
