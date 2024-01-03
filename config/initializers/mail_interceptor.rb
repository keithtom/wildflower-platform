require 'interceptors/reroute_email_interceptor'
require 'interceptors/cypress_email_interceptor'

if Rails.env.development? || Rails.env.staging?
  ActionMailer::Base.register_interceptor(Interceptors::RerouteEmailInterceptor)
  ActionMailer::Base.register_interceptor(Interceptors::CypressEmailInterceptor)
end