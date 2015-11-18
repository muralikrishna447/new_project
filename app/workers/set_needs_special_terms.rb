class SetNeedsSpecialTerms
  @queue = :set_needs_special_terms
  
  def self.perform(email)
    Rails.logger.info "Setting need special terms for email #{email}"
    user = User.where(email: email).first
    unless user
      raise "No user found with email #{email}"
    end

    user.needs_special_terms = true
    user.save!
    user.actor_addresses.each do |aa|
      Rails.logger.info "Double incrementing actor address with id #{aa.id}"
      aa.double_increment
    end
    Rails.logger.info "Finished for user #{user.id}"
  end
end
