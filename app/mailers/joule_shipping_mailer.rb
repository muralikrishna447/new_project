class JouleShippingMailer < ActionMailer::Base
  default from: "Team ChefSteps <no-reply@chefsteps.com>"
  default reply_to: "no-reply@chefsteps.com"

  def prepare(user)
    logger.info("Preparing joule shipping mail for user [#{user.email}]")
    subject = "The First Joules Have Shipped!"
    substitutions = {
      sub: {
        "*|CURRENT_YEAR|*" => [Time.now.year]
      }
    }
    headers['X-SMTPAPI'] = substitutions.to_json
    headers['X-IDEMPOTENCY'] = "The First Joules Have Shipped!3"
    mail(to: user.email, subject: subject)
  end
end
