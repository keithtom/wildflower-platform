# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name("platform@email.wildflowerschools.org", ENV['APP_NAME']), # for deliverability with mailgun domain
          reply_to: email_address_with_name("support@wildflowerschools.org", "Wildflower Support")
  layout 'mailer'
end
