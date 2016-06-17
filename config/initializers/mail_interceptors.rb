unless Rails.env.production? || Rails.env.test?
  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor)
end

ActionMailer::Base.register_interceptor(IdempotentMailInterceptor)
ActionMailer::Base.register_observer(IdempotentMailInterceptor)
