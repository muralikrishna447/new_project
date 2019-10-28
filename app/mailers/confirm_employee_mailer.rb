class ConfirmEmployeeMailer < ActionMailer::Base
  default from: 'Team ChefSteps <noreply@chefsteps.com>'
  layout 'mailer'

  def prepare(email_address, token)
    raise 'token is required' if token.to_s.empty?

    subject = "You're in."
    substitutions = {
      sub: {
        '*|SUBJECT|*' => [subject],
        '*|BASE_URL|*' => [base_url],
        '*|TOKEN|*' => [token]
      }
    }
    headers['X-SMTPAPI'] = substitutions.to_json
    headers['X-IDEMPOTENCY'] = "#{subject} #{Time.now.utc.iso8601}"
    mail(to: email_address, subject: subject)
  end

  def base_url
    "https://www.#{Rails.application.config.shared_config[:chefsteps_endpoint]}"
  end
end
