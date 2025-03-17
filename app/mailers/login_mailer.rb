class LoginMailer < ApplicationMailer
  default bcc: 'support@wildflowerschools.org'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.login_mailer.invite.subject
  #

  def login(user)
    @user = user
    @login_url = "#{ENV.fetch('FRONTEND_URL', nil)}/token?token=#{user.authentication_token}"
    mail to: @user.email, subject: 'Login to My Wildflower Platform'
  end

  def password_reset(user)
    @user = user
    @invite_url = "#{ENV.fetch('FRONTEND_URL', nil)}/token?token=#{user.authentication_token}&redirect=/reset-password"

    mail(
      to: @user.email,
      subject: "Password Reset Request - #{ENV.fetch('APP_NAME', 'Wildflower Platform')}"
    )
  end
end
