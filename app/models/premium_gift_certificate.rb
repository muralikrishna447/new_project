class PremiumGiftCertificate < ActiveRecord::Base
  attr_accessible :purchaser_id, :price, :sales_tax, :redeemed
  belongs_to :user, foreign_key: :purchaser_id, inverse_of: :premium_gift_certificates

  scope :free_gifts, -> { where(price: 0) }
  scope :unredeemed, -> { where(redeemed: false) }

  include ActsAsChargeable

  after_initialize do
    if ! self.token
      loop do
        # 6 chars incluing 0-9, a-z, should give us 36^6 = 2,176,782,336 possibilities. Enough
        # to keep crackers at bay. Loop to avoid (extremely rare) duplicate.
        self.token = SecureRandom.urlsafe_base64.downcase.delete('_-')[0..5]
        break unless PremiumGiftCertificate.unscoped.exists?(token: self.token)
      end
    end
  end

  def self.redeem(user, token)
    gc = PremiumGiftCertificate.where(token: token.to_s).last
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
