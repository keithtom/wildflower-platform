class SchoolRelationshipMailer < ApplicationMailer
  default bcc: 'support@wildflowerschools.org'

  def add_partner(user_id, school_name)
    @user = User.find(user_id)
    @school_name = school_name

    @invite_url = "#{ENV.fetch('FRONTEND_URL', nil)}/token?token=#{@user.authentication_token}"

    mail to: @user.email, cc: 'support@wildflowerschools.org',
         subject: "#{ENV.fetch('APP_NAME', 'My Wildflower')} - You have been added to the #{@school_name} dashboard"
  end
end
