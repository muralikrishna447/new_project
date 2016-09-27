class JouleShippingSender
  @queue = :JouleShippingSender
  def self.perform(user_id)
    
    user = User.find(user_id)
    Rails.logger.info "Starting JouleShippingSender job for user with email: [#{user.email}]"
    JouleShippingMailer.prepare(user).deliver
  end
end
