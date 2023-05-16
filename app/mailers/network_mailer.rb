class NetworkMailer < ApplicationMailer
  def invite(user)
    @user = user
    
    # invite link takes ppl to a front end.  e.g. id.wildflowerschools.org.  here this page sends a request to create a session with the token.
    # TODO: this should specify a redirect to the SSJ onboard if we are inviting them into the SSJ
    link = CGI.escape("#{ENV['FRONTEND_URL']}/welcome/existing-tl")
    @invite_url = "#{ENV['FRONTEND_URL']}/token?token=#{user.authentication_token}&redirect=#{link}"

    mail to: @user.email, subject: "Welcome to the Wildflower Platform!"
  end
end