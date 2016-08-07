class JouleRefundMailer < ActionMailer::Base
  default from: "Team ChefSteps <info@chefsteps.com>"
  default reply_to: "info@chefsteps.com"

  def prepare(user)
    logger.info("Preparing joule refund mail for user [#{user.email}]")
    subject = "New Price for Joule, Money Back for You? Damn Straight."
    substitutions = {
      sub: {
        "*|SUBJECT|*" => [subject],
        "*|NAME|*" => [user.name],
        "*|CURRENT_YEAR|*" => [Time.now.year]
      }
    }
    headers['X-SMTPAPI'] = substitutions.to_json
    headers['X-IDEMPOTENCY'] = "2016-08-08 New Price for Joule, Money Back for You? Damn Straight."
    mail(to: user.email, subject: subject)
  end
end
