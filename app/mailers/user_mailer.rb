class UserMailer < ActionMailer::Base
  default from: "info@chefsteps.com"

  def invitations(to, sender, from="google_invite", custom_text="")
    @sender = sender
    @from = from
    @custom_text = custom_text
    mail(bcc: to, subject: "Join #{@sender.name} on ChefSteps and cook smarter")
  end
end
