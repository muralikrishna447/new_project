class DeclinedMailer < BaseMandrillMailer
  def joule(user)
    subject = "ChefSteps Joule Payment - Your card was declined"
    # template = "joule-credit-card-declined"
    template_id = 'c1d0f084-4fc6-4b9e-8aca-af12618c53ff'
    common_mail(subject, template_id, user)
  end

  def premium(user)
    subject = "ChefSteps Premium Payment - Your card was declined"
    template = "premium-credit-card-declined"
    common_mail(subject, template, user)
  end


  def common_mail(subject, template_id, user)
    subject = subject
    merge_vars = {
      "NAME" => user.name
    }
    recipient = SendGrid::Recipient.new(user.email)
    recipient.add_substitution('NAME', user.first_name)
    mailer = sendgrid_mailer(template_id,user.email)

    mail_defaults = {
      from: 'info@chefsteps.com',
      subject: subject
    }
    mailer.mail(mail_defaults)
    # body = mandrill_template(template, merge_vars)
    # mail(to: user.email, subject: subject, body: body, content_type: "text/html", from: 'ellenk@chefsteps.com', reply_to: 'ellenk@chefsteps.com')
  end
end
