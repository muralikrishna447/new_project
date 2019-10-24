class EmployeeAccountProcessor
  @queue = :employee_account_processor

  EMPLOYEE_EMAIL_DOMAINS = %w(
    chefsteps.com
    breville.com
    breville.com.au
    breville.ca
    brevilleusa.com
    sageappliances.com
    sageappliances.co.uk
    polyscienceculinary.com
  ).freeze

  CONFIRM_EMAIL_EXPIRATION = 1.year.freeze

  TOKEN_RESTRICTION = 'confirm_employee_email'.freeze

  def self.perform(user_id)
    user = User.find(user_id)
    return unless user

    return unless has_employee_email?(user)

    Rails.logger.info("EmployeeAccountProcessor user with ID #{user_id} has employee email #{user.email}")
    ConfirmEmployeeMailer.prepare(user.email, create_token_for_user(user)).deliver
  end

  def self.user_eligible?(user)
    return true if has_employee_email?(user)
    return true if has_whitelisted_email?(user)
    false
  end

  # Use this environment variable for testing some whitelisted
  # email if it is not an official company email domain.
  def self.has_whitelisted_email?(user)
    return true if user.email == ENV['EMPLOYEE_WHITELIST_EMAIL']
    false
  end

  def self.has_employee_email?(user)
    EMPLOYEE_EMAIL_DOMAINS.each do |domain|
      return true if user.email.end_with?("@#{domain}")
    end
    false
  end

  def self.create_token_for_user(user)
    aa = ActorAddress.create_for_user(user, client_metadata: TOKEN_RESTRICTION)
    exp = ((Time.now + CONFIRM_EMAIL_EXPIRATION).to_f * 1000).to_i
    aa.current_token(exp: exp, restrict_to: TOKEN_RESTRICTION).to_jwt
  end
end
