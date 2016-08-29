class JouleRefundMailer < ActionMailer::Base
  default from: "Team ChefSteps <info@chefsteps.com>"
  default reply_to: "info@chefsteps.com"

  def prepare(user, refund_amount)
    logger.info("Preparing joule refund mail for user [#{user.email}]")
    subject = "Here Comes Your Refund!"
    substitutions = {
      sub: {
        "*|SUBJECT|*" => [subject],
        "*|NAME|*" => [user.name],
        "*|CURRENT_YEAR|*" => [Time.now.year],
        "*|REFUND_AMOUNT|*" => [refund_amount]
      }
    }
    headers['X-SMTPAPI'] = substitutions.to_json
    headers['X-IDEMPOTENCY'] = "Here comes your refund!"
    mail(to: user.email, subject: subject)
  end
end
