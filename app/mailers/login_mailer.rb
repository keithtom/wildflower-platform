class LoginMailer < ApplicationMailer
  include RedirectHelper

  default bcc: "maggie.paulin@wildflowerschools.org"
  
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.login_mailer.invite.subject
  #

  def login(user)
    @user = user
    link = CGI.escape("#{ENV['FRONTEND_URL']}#{redirect_path(user)}")
    @login_url = "#{ENV['FRONTEND_URL']}/token?token=#{user.authentication_token}&redirect=#{link}"
    mail to: @user.email, subject: "Login to My Wildflower Platform"
  end
end
