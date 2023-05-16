module Interceptors
  class RerouteEmailInterceptor
    def self.delivering_email(mail)
        original_to = mail.header[:to].to_s
        original_subject = mail.header[:subject].to_s

        mail.to = rerouted_email_address
        mail.subject = "#{original_subject} [originally to: #{original_to}]"

        if mail.cc.present?
          original_cc_emails = mail.cc.dup.join(", ")
          mail.cc = []
          mail.subject = "#{original_subject} [originally cc: #{original_cc_emails}, to: #{original_to}]"
        end

        Rails.logger.info "Rerouted '#{original_to}' to '#{rerouted_email_address}'."
      end
    end

    def self.rerouted_email_address
      @rerouted_email_address ||= ["keith.tom+#{Rails.env}@wildflowerschools.org", "li.ouyang+#{Rails.env}@wildflowerschools.org"]
    end
  end
end