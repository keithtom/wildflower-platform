class SSJMailer < ApplicationMailer
  default bcc: "support@wildflowerschools.org"
  
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.invite.subject
  #
  # from: should ideally come from their operations guide or the platform?
  # cc: ops guide?
  def invite_partner(user, inviter)
    @user = user
    @inviter = inviter
    @ops_guide = SSJ::TeamMember.find_by!(status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::OPS_GUIDE)&.person

    # invite link takes ppl to a front end.  e.g. id.wildflowerschools.org.  here this page sends a request to create a session with the token.
    # TODO: this should specify a redirect to the SSJ onboard if we are inviting them into the SSJ
    link = CGI.escape("#{ENV['FRONTEND_URL']}/welcome/existing-tl")
    @invite_url = "#{ENV['FRONTEND_URL']}/token?token=#{user.authentication_token}&redirect=#{link}"

    mail to: @user.email, cc: [@ops_guide.email, "support@wildflowerschools.org"], subject: "Welcome to the School Startup Journey!"
  end

  def invite(user_id, ops_guide_id)
    @user = User.find(user_id) # the ETL who is being invited
    @ops_guide = User.find(ops_guide_id)

    # invite link takes ppl to a front end.  e.g. id.wildflowerschools.org.  here this page sends a request to create a session with the token.
    # TODO: this should specify a redirect to the SSJ onboard if we are inviting them into the SSJ
    link = CGI.escape("#{ENV['FRONTEND_URL']}/welcome/new-etl")
    @invite_url = "#{ENV['FRONTEND_URL']}/token?token=#{@user.authentication_token}&redirect=#{link}"

    mail to: @user.email, cc: @ops_guide.email, subject: "Welcome to the School Startup Journey!"
  end

  def invite_ops_guide(user, ssj_team)
    @user = user
    link = CGI.escape("#{ENV['FRONTEND_URL']}/ssj?team=#{ssj_team.external_identifier}") # TODO: this should be a specific dashboard
    @dashboard_url = "#{ENV['FRONTEND_URL']}/token?token=#{user.authentication_token}&redirect=#{link}"
    @partner_names = ssj_team.partner_members.map(&:person).map(&:first_name).to_sentence

    mail to: @user.email, subject: "SSJ Dashboard: You have a new team!"
  end
end
