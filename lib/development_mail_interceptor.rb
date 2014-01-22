class DevelopmentMailInterceptor
  def self.delivering_email(message)
    all_to = [message.to,message.bcc,message.cc].compact.join(",")
    message.subject = "#{all_to} #{message.subject}"
    message.to = "dev@chefsteps.com"
    message.bcc = nil
    message.cc = nil
  end
end