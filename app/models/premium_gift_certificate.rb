class PremiumGiftCertificate < ApplicationRecord

  belongs_to :user, foreign_key: :purchaser_id#, inverse_of: :premium_gift_certificates

  scope :free_gifts, -> { where(price: 0) }
  scope :unredeemed, -> { where(redeemed: false) }

  after_initialize do
    self.token = self.token || unique_code { |token| PremiumGiftCertificate.unscoped.exists?(token: token) }
  end

  def self.redeem(user, token)
    gc = PremiumGiftCertificate.where(token: token.to_s).last
    gc = PremiumGiftCertificate.where('lower(token) = ?', token.to_s.downcase).last if gc == nil
    raise "Gift certificate #{token} not found" if gc == nil
    raise "Gift certificate #{token} already redeemed" if gc.redeemed
    enrollment = nil
    PremiumGiftCertificate.transaction do
      gc.redeemed = true
      gc.save!
      user.make_premium_member(gc.price)
    end
  end
end
