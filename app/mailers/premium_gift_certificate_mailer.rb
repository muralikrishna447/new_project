class PremiumGiftCertificateMailer < ActionMailer::Base

  default from: ENV['CS_APPLICATION_MAILER_DEFAULT_FROM'] || 'Team ChefSteps <no-reply@chefsteps.com>'

  def prepare(user_email, redeem_token)
    subject = "ChefSteps Premium Gift Certificate"

    substitutions = {
      sub: {
        "*|SUBJECT|*" => [subject],
        "*|REDEEM_TOKEN|*" => [redeem_token],
        "*|CURRENT_YEAR|*" => [Time.now.year]
      }
    }
    headers['X-SMTPAPI'] = substitutions.to_json
    mail(to: user_email, subject: subject)
  end
end
