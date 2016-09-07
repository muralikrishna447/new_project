class JouleAddressMailer < ActionMailer::Base
  default from: "Team ChefSteps <info@chefsteps.com>"
  default reply_to: "info@chefsteps.com"

  def prepare(user)
    logger.info("Preparing joule address change mail for user [#{user.email}]")
    subject = "Important: Verify Your Shipping Address For Joule"
    substitutions = {
      sub: {
        "*|SUBJECT|*" => [subject],
        "*|NAME|*" => [user.name],
        "*|CURRENT_YEAR|*" => [Time.now.year]
      }
    }
    headers['X-SMTPAPI'] = substitutions.to_json
    headers['X-IDEMPOTENCY'] = "Important: Verify Your Shipping Address For Joule"
    mail(to: user.email, subject: subject)
  end
end
