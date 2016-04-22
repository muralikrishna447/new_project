unless Rails.env.production? || Rails.env.test?
  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor)
end
