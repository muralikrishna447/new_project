class TermsUpdateMailer < ActionMailer::Base
  default from: 'Team ChefSteps <no-reply@chefsteps.com>'
  default reply_to: 'Team ChefSteps <no-reply@chefsteps.com>'

  def prepare(email_address, terms_version)
    Rails.logger.info "Preparing TermsUpdateMailer for email address #{email_address} and terms version #{terms_version}"

    subject = 'Hello. We\'ve Updated Our Privacy Policy.'
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
