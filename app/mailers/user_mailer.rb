class UserMailer < ActionMailer::Base
  default from: "info@chefsteps.com"

  def invitations(to, sender)
    @sender = sender
    mail(bcc: to, subject: "Join #{sender.name} on ChefSteps and cook smarter")
  end
end
