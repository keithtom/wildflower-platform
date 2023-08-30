class LoginMailer < ApplicationMailer
  default bcc: "maggie.paulin@wildflowerschools.org"
  
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.invite.subject
  #

  def login(user)
    @user = user
    @login_url = "#{ENV['FRONTEND_URL']}/token?token=#{user.authentication_token}"
    mail to: @user.email, subject: "Login to My Wildflower Platform"
  end
end
