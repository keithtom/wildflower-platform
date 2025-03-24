class SchoolMailer < ApplicationMailer
  include Mailers::NameFormatterHelper

  default bcc: 'support@wildflowerschools.org'

  # Generic email to notify a partner that they have been added to a school dashboard
  def add_partner(user_id, school_name)
    @user = User.find(user_id)
    @school_name = school_name

    @invite_url = "#{ENV.fetch('FRONTEND_URL', nil)}/token?token=#{@user.authentication_token}"

    mail to: @user.email, cc: 'support@wildflowerschools.org',
         subject: "#{ENV.fetch('APP_NAME', 'My Wildflower')} - You have been added to the #{@school_name} dashboard"
  end

  # Gets sent to all active users associated with the school, letting them know that they have access to a new workflow
  def notify_partners_new_workflow(school_id)
    @school = School.find(school_id)
    @partners = @school&.active_partners

    @login_url = "#{ENV.fetch('FRONTEND_URL', nil)}/login"
    mail to: @partners.pluck(:email), cc: 'support@wildflowerschools.org',
         subject: "#{ENV.fetch('APP_NAME', 'My Wildflower')} - You have access to a new tool!"
  end
end
