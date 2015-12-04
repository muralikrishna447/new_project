class DeclinedMailer < BaseMandrillMailer
  def joule(user)
    subject = "ChefSteps Joule Payment - Your card was declined"
    template = "joule-credit-card-declined"
    common_mail(subject, template)
  end

  def premium(user)
    subject = "ChefSteps Premium Payment - Your card was declined"
    template = "premium-credit-card-declined"
    common_mail(subject, template)
  end


  def common_mail(subject, template)
    subject = subject
    merge_vars = {
      "NAME" => user.name
    }
    body = mandrill_template(template, merge_vars)
    mail(to: user.email, subject: subject, body: body, content_type: "text/html", from: 'ellenk@chefsteps.com', reply_to: 'ellenk@chefsteps.com')
  end
end
