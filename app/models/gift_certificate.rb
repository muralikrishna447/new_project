class GiftCertificate < ActiveRecord::Base
  attr_accessible :purchaser_id, :assembly_id, :price, :sales_tax, :recipient_email, :recipient_name, :recipient_message
  belongs_to :user, foreign_key: :purchaser_id, inverse_of: :gift_certificates
  belongs_to :assembly, inverse_of: :gift_certificates 
  include ActsAsChargeable

  after_initialize do
    loop do
      self.token = SecureRandom.urlsafe_base64(6)
      break unless GiftCertificate.unscoped.exists?(token: self.token)
    end
  end

  def self.purchase(purchaser, ip_address, assembly, discounted_price, stripe_token, gift_info)

    # We create the gift cert first, but wrap this whole block in a transaction, so if the stripe chage then fails,
    # the enrollment is rolled back. The exception will then be re-raised and should be handled
    # by the caller. You don't want to charge first and then create the enrollement, b/c if
    # the charge succeeds and the enrollment fails, you are hosed.
    @gc = nil
    GiftCertificate.transaction do 
      gross_price, tax, extra_descrip = get_tax_info(assembly.price, discounted_price, ip_address)
      @gc = GiftCertificate.create!(
              purchaser_id: purchaser.id, 
              assembly_id: assembly.id, 
              price: gross_price, 
              sales_tax: tax, 
              recipient_email: gift_info["recipientEmail"], 
              recipient_name: gift_info["recipientName"], 
              recipient_message: gift_info["recipientMessage"]
            )
      collect_money(assembly.price, discounted_price, assembly.title, extra_descrip, purchaser, stripe_token)
    end

    @gc
  end
end
