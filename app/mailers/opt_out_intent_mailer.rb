class OptOutIntentMailer < ActionMailer::Base
  default from: 'Team ChefSteps <info@chefsteps.com>'
  default reply_to: 'Breville Privacy <privacy@breville.com>'

  def prepare(email_address, token, version)
    raise 'token is required' if token.to_s.empty?
    raise 'version param is required' if version.to_s.empty?

    Rails.logger.info "Preparing OptOutIntentMailer for email address #{email_address} and version #{version}"

    subject = 'test'
    substitutions = {
      sub: {
        '*|SUBJECT|*' => [subject],
        '*|BASE_URL|*' => [base_url],
        '*|TOKEN|*' => [token]
      }
    }
    headers['X-SMTPAPI'] = substitutions.to_json
    headers['X-IDEMPOTENCY'] = "#{subject} #{version}"
    mail(to: email_address, subject: subject)
  end

  def base_url
    if Rails.env.development?
      'http://localhost:3000'
    elsif Rails.env.staging?
      'https://www.chocolateyshatner.com'
    elsif Rails.env.staging2?
      'https://www.vanillanimoy.com'
    else
      'https://www.chefsteps.com'
    end
  end
end
