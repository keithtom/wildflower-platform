class SSJMailer < ApplicationMailer
  default bcc: "support@wildflowerschools.org"
  
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.invite.subject
  #
  # from: should ideally come from their operations guide or the platform?
  # cc: ops guide?
  def invite_partner(user_id, inviter_id, ops_guide_id)
    @user = User.find(user_id)
    @inviter = User.find(inviter_id)
    @ops_guide = Person.find(ops_guide_id)

    # invite link takes ppl to a front end.  e.g. id.wildflowerschools.org.  here this page sends a request to create a session with the token.
    @invite_url = "#{ENV['FRONTEND_URL']}/token?token=#{@user.authentication_token}"

    mail to: @user.email, cc: [@ops_guide.email, "support@wildflowerschools.org"], subject: "Welcome to the School Startup Journey!"
  end

  def invite(user_id, ops_guide_id)
    @user = User.find(user_id) # the ETL who is being invited
    @ops_guide = User.find(ops_guide_id)

    # invite link takes ppl to a front end.  e.g. id.wildflowerschools.org.  here this page sends a request to create a session with the token.
    @invite_url = "#{ENV['FRONTEND_URL']}/token?token=#{@user.authentication_token}"

    mail to: @user.email, cc: @ops_guide.email, subject: "Welcome to the School Startup Journey!"
  end

  def invite_ops_guide(user, ssj_team)
    @user = user
    @dashboard_url = "#{ENV['FRONTEND_URL']}/token?token=#{user.authentication_token}"
    @partner_names = ssj_team.partner_members.map(&:person).map(&:first_name).to_sentence

    mail to: @user.email, subject: "SSJ Dashboard: You have a new team!"
  end
end
