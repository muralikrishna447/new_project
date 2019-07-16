class TermsUpdateMailer < ActionMailer::Base
  default from: 'Team ChefSteps <info@chefsteps.com>'
  default reply_to: 'Breville Privacy <privacy@breville.com>'

  def prepare(email_address, terms_version)
    raise 'terms_version param is required' if terms_version.to_s.empty?

    Rails.logger.info "Preparing TermsUpdateMailer for email address #{email_address} and terms version #{terms_version}"

    subject = 'ChefSteps - Breville joint notice and Privacy Policy update.'
    substitutions = {
      sub: {
        '*|SUBJECT|*' => [subject],
        '*|CURRENT_YEAR|*' => [Time.now.year]
      }
    }
    headers['X-SMTPAPI'] = substitutions.to_json
    headers['X-IDEMPOTENCY'] = "#{subject} #{terms_version}"
    mail(to: email_address, subject: subject)
  end

  def prepare_eu(email_address, terms_version)
    raise 'terms_version param is required' if terms_version.to_s.empty?

    Rails.logger.info "Preparing TermsUpdateMailer for email address #{email_address} and terms version #{terms_version} for EU version"

    subject = 'ChefSteps - Breville joint notice and Privacy Policy update.'
    substitutions = {
      sub: {
        '*|SUBJECT|*' => [subject],
        '*|CURRENT_YEAR|*' => [Time.now.year]
      }
    }
    headers['X-SMTPAPI'] = substitutions.to_json
    headers['X-IDEMPOTENCY'] = "#{subject} #{terms_version}"
    mail(to: email_address, subject: subject)
  end
end
