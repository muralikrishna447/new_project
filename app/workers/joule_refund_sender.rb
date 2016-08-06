class JouleRefundSender
  @queue = :JouleRefundSender
  def self.perform(email)
    Rails.logger.info "Starting JouleRefundSender job for email [#{email}]"
    user = User.where(email: email).first
    JouleRefundMailer.prepare(user).deliver
  end
end
