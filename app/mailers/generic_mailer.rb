class GenericMailer < ActionMailer::Base
  default from: "info@chefsteps.com"

  def recipient_email(to_recipient, subject, recipient_message)
    @recipient_message = recipient_message
    mail(to: to_recipient, subject: subject)
  end
end
