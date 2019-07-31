require 'aws-sdk'

class OptOutIntentSender
  @queue = :OptOutIntentSender

  def self.perform(email_address, token, version)
    raise 'token is required' if token.to_s.empty?
    raise 'version param is required' if version.to_s.empty?

    Rails.logger.info "Starting OptOutIntentSender job for email address #{email_address} and version #{version}"
    OptOutIntentMailer.prepare(email_address, token, version).deliver
  end

  # Reads a text file containing email addresses from S3, one per line.
  def self.email_addresses_from_s3(region, bucket, path)
    s3 = Aws::S3::Resource.new(region: region)
    body = s3.bucket(bucket).object(path).get.body.read
    body.split("\n")
  end

  def self.enqueue_emails(email_addresses, version)
    user_list = create_tokens_for_users(map_users_to_email_addresses(email_addresses))

    user_list.each do |row|
      unless row[:user]
        Rails.logger.warn "OptOutIntentSender no user found with email #{row[:email_address]}, skipping"
        next
      end
      Resque.enqueue(OptOutIntentSender, row[:email_address], row[:token], version)
    end
  end

  def self.map_users_to_email_addresses(email_addresses)
    email_addresses.map do |email_address|
      { email_address: email_address, user: User.find_by_email(email_address) }
    end
  end

  def self.create_tokens_for_users(user_list)
    user_list.each do |row|
      row[:token] = row[:user].valid_website_auth_token.to_jwt if row[:user]
    end
  end
end
