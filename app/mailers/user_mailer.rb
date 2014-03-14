class UserMailer < ActionMailer::Base
  default from: "info@chefsteps.com"

  def invitations(to, sender, from="google_invite")
    @sender = sender
    @from = from
    mail(bcc: to, subject: "Join #{@sender.name} on ChefSteps and cook smarter")
  end
end
