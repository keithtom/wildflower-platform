# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "Wildflower Platform <platform@wildflowerschools.org>"
  layout 'mailer'
end
