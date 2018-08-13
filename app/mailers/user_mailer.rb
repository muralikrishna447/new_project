class UserMailer < ActionMailer::Base
  default from: "info@chefsteps.com"

  def invitations(to, sender, from="google_invite", custom_text="")
    @sender = sender
    @from = from
    @custom_text = custom_text
    mail(bcc: to, subject: "Join #{@sender.name} on ChefSteps and cook smarter")
  end

  def reset_password(to, token)
    @token = token
    host = 'https://' + DOMAIN
    @update_password_link = host + "/passwords/edit_from_email/#/?token=#{token}"
    mail(to: to, subject: "ChefSteps Password Reset")
  end
end
