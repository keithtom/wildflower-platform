class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.invite.subject
  #
  # from should ideally come from their operations guide or the platform?
  # cc ops guide?
  def invite(user)
    @user = user # the ETL who is being invited
    @invite_url = user_token_url(token: user.authentication_token)

    mail to: @user.email, subject: "Welcome to the School Startup Journey!"
  end
end
