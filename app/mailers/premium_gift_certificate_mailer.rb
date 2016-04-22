class PremiumGiftCertificateMailer < ActionMailer::Base

  default from: "info@chefsteps.com"

  def prepare(user, redeem_token)
    subject = "ChefSteps Premium Gift Certificate"

    substitutions = {
      sub: {
        "*|SUBJECT|*" => [subject],
        "*|REDEEM_TOKEN|*" => [redeem_token],
        "*|CURRENT_YEAR|*" => [Time.now.year]
      }
    }
    headers['X-SMTPAPI'] = substitutions.to_json
    mail(to: user.email, subject: subject)
  end
end
