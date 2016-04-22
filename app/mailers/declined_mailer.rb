class DeclinedMailer < ActionMailer::Base

  default from: "info@chefsteps.com"

  def joule(user)
    subject = "ChefSteps Joule Payment - Your card was declined"
    template = "joule-credit-card-declined"
    common_mail(subject, template, user)
  end

  def premium(user)
    subject = "ChefSteps Premium Payment - Your card was declined"
    template = "premium-credit-card-declined"
    common_mail(subject, template, user)
  end


  def common_mail(subject, template, user)
    subject = subject
    substitutions = {
      sub: {
        "*|SUBJECT|*" => [subject],
        "*|NAME|*" => [user.name]
      }
    }
    headers['X-SMTPAPI'] = substitutions.to_json
    mail(to: user.email, subject: subject, content_type: "text/html", from: 'ellenk@chefsteps.com', reply_to: 'ellenk@chefsteps.com')
  end
end
