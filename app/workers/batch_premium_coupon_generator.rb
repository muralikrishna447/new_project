class BatchPremiumCouponGenerator
  @queue = 'BatchPremiumCouponGenerator'

  def self.perform(id)
    Rails.logger.info("BatchPremiumCouponGenerator starting to perform for #{id}")
    cert_group = PremiumGiftCertificateGroup.find(id)
    cert_group.coupon_count.times.each do
      PremiumGiftCertificate.create(premium_gift_certificate_group_id: id)
    end
    cert_group.update_columns(coupon_creation_status: true)
    Rails.logger.info("BatchPremiumCouponGenerator processed for #{id}")
  end

end
