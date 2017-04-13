class TermsUpdateSender
  @queue = :TermsUpdateSender

  def self.perform(email_address, terms_version)
    raise 'terms_version param is required' unless terms_version

    Rails.logger.info "Starting TermsUpdateSender job for email address #{email_address} and terms version #{terms_version}"
    TermsUpdateMailer.prepare(email_address, terms_version).deliver
  end
end
