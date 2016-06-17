unless Rails.env.production? || Rails.env.test?
  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor)
end

# TODO - figure out best way to update the many tests that try to send email
unless Rails.env.test?
  ActionMailer::Base.register_interceptor(IdempotentMailInterceptor)
  ActionMailer::Base.register_observer(IdempotentMailInterceptor)
end
