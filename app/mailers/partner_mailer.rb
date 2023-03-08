class PartnerMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.invite.subject
  #
  # from: should ideally come from their operations guide or the platform?
  # cc: ops guide?
  def invite(user)
    @user = user # the ETL who is being invited

    # invite link takes ppl to a front end.  e.g. id.wildflowerschools.org.  here this page sends a request to create a session with the token.
    # TODO: this should specify a redirect to the SSJ onboard if we are inviting them into the SSJ
    link = CGI.escape("https://platform.wildflowerschools.org/welcome/existing-tl")
    @invite_url = "https://platform.wildflowerschools.org/token?token=#{user.authentication_token}&redirect=#{link}"

    mail to: @user.email, subject: "Welcome to the School Startup Journey!"
  end
end
