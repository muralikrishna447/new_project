require 'aws-sdk'

class TermsUpdateSender
  @queue = :TermsUpdateSender

  def self.perform(email_address, terms_version, type)
    raise 'terms_version param is required' if terms_version.to_s.empty?

    if type.to_sym == :eu
      Rails.logger.info "Starting TermsUpdateSender job for email address #{email_address} and terms version #{terms_version} EU"
      TermsUpdateMailer.prepare_eu(email_address, terms_version).deliver
    elsif type.to_sym == :main
      Rails.logger.info "Starting TermsUpdateSender job for email address #{email_address} and terms version #{terms_version}"
      TermsUpdateMailer.prepare(email_address, terms_version).deliver
    elsif type.to_sym == :inquiry_response
      Rails.logger.info "Starting TermsUpdateSender job for email address #{email_address} and terms version #{terms_version}"
      TermsUpdateMailer.prepare_inquiry_response(email_address, terms_version).deliver
    else
      raise "Unknown mailer type #{type}"
    end
  end

  # Reads a text file containing email addresses from S3, one per line.
  def self.email_addresses_from_s3(region, bucket, path)
    s3 = Aws::S3::Resource.new(region: region)
    body = s3.bucket(bucket).object(path).get.body.read
    body.split("\n")
  end

  # Enqueues sender jobs for an array of email addresses and a specific
  # version of the terms.
  def self.enqueue_emails(email_addresses, terms_version, type = :main)
    email_addresses.each do |address|
      Resque.enqueue(TermsUpdateSender, address, terms_version, type)
    end
  end
end
