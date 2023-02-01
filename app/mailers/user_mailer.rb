class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.invite.subject
  #
  # from should ideally come from their operations guide or the platform?
  # cc ops guide?
  def invite
    @user = User.first #  params[:user] # the ETL who is being invited
    @invite_url = "#" # generate a special user specific login link.

    mail to: @user.email, subject: "Welcome to the School Startup Journey!"
  end
end
