if Rails.env.development? || Rails.env.staging?
  ActionMailer::Base.register_interceptor(Interceptors::RerouteEmailInterceptor)
end