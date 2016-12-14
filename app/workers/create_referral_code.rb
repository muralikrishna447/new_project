class CreateReferralCode
  @queue = :create_referral_code
  def self.perform(user_id)
    logger.info("Creating referral code for #{user_id}")
  end
end
