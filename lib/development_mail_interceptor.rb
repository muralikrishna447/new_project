class DevelopmentMailInterceptor
  def self.delivering_email(message)

    # Allow emails to chefsteps employees to send normally
    unless message.to.first.match /@chefsteps.com$/
      all_to = [message.to,message.bcc,message.cc].compact.join(",")
      message.to = "dev@chefsteps.com"
      message.subject += " [#{all_to}]"
    end

    message.subject += " [#{Rails.env}]"
    message.bcc = nil
    message.cc = nil
  end
end
