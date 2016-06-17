class JouleShipDateMailer < ActionMailer::Base
  default from: "Team ChefSteps <info@chefsteps.com>"
  default reply_to: "info@chefsteps.com"

  def prepare(user)
    logger.info("Preparing joule ship date mail for user [#{user.email}]")
    subject = "Your Joule Will Ship in September!"
    substitutions = {
      sub: {
        "*|SUBJECT|*" => [subject],
        "*|NAME|*" => [user.name],
        "*|CURRENT_YEAR|*" => [Time.now.year]
      }
    }
    headers['X-SMTPAPI'] = substitutions.to_json
    headers['X-IDEMPOTENCY'] = "2016-06-20 Your Joule Will Ship in September!"
    mail(to: user.email, subject: subject)
  end
end
