# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name("platform@wildflowerschools.org", "Wildflower Platform")
  layout 'mailer'
end
