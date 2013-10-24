class GiftCertificate < ActiveRecord::Base
  belongs_to :user, foreign_key: :purchaser_id, inverse_of: :gift_certificates

  after_initialize do
    loop do
      self.token = SecureRandom.urlsafe_base64(6)
      break unless GiftCertificate.unscoped.exists?(token: self.token)
    end
  end
end
