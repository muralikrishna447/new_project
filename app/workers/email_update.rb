class EmailUpdate
  @queue = :user_sync

  def self.perform(user_id, old_email_address, new_email_address)
    # Old and new email addresses included as these will be persisted in redis
    user = User.find(user_id)
    if user.email != new_email_address
      msg = "Current email [#{user.email}] does not match expected [#{new_email_address}]"
      Rails.logger.info msg
      raise msg
    end
    
    Shopify::Customer.update_email(user, old_email_address)
  end
end
