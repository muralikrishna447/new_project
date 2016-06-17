class JouleShipDateSender
  @queue = :joule_ship_date_sender
  def self.perform(email)
    Rails.logger.info "Starting JouleShipDateSender job for email [#{email}]"
    user = User.where(email: email).first
    JouleShipDateMailer.prepare(user).deliver
  end
end
