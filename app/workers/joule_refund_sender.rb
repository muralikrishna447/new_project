class JouleRefundSender
  @queue = :JouleRefundSender
  def self.perform(user_id, refund_amount)
    user = User.find(user_id)
    Rails.logger.info "Starting JouleRefundSender job for user with email: [#{user.email}] for refund_amount: $#{refund_amount} "
    JouleRefundMailer.prepare(user, refund_amount).deliver
  end
end
