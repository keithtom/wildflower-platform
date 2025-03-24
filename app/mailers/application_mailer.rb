# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name('platform@email.wildflowerschools.org', ENV.fetch('APP_NAME', nil)), # for deliverability with mailgun domain
          reply_to: email_address_with_name('support@wildflowerschools.org', 'Wildflower Support')
  layout 'mailer'

  helper do
    def format_names(partners)
      return partners.first&.first_name if partners.size <= 1

      "#{partners[0..-2].map(&:first_name).join(', ')} and #{partners.last.first_name}"
    end
  end
end
