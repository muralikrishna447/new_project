class GiftCertificate < ActiveRecord::Base
  attr_accessible :purchaser_id, :assembly_id, :price, :sales_tax, :recipient_email, :recipient_name, :recipient_message, :redeemed, :email_to_recipient
  belongs_to :user, foreign_key: :purchaser_id, inverse_of: :gift_certificates
  belongs_to :assembly, inverse_of: :gift_certificates

  scope :free_gifts, -> { where(price: 0) }
  scope :unredeemed, -> { where(redeemed: false) }
  scope :one_week_old, -> { where('created_at < ?', 1.week.ago)}
  scope :not_followed_up, -> { where(followed_up: false)}
  scope :recipients_to_email, -> { where(email_to_recipient: true) }

  include ActsAsChargeable

  after_initialize do
    if ! self.token
      loop do
        # 6 chars incluing 0-9, a-z, should give us 36^6 = 2,176,782,336 possibilities. Enough
        # to keep crackers at bay. Loop to avoid (extremely rare) duplicate.
        # I wonder if I should be worried about the possibility of it generating something offensive.
        # puts "NEW TOKEN!!"
        self.token = SecureRandom.urlsafe_base64.downcase.delete('_-')[0..5]
        # puts self.token
        break unless GiftCertificate.unscoped.exists?(token: self.token)
      end
    end
  end

  def self.purchase(purchaser, ip_address, assembly, discounted_price, stripe_token, gift_info, existing_card=nil)

    # We create the gift cert first, but wrap this whole block in a transaction, so if the stripe chage then fails,
    # the enrollment is rolled back. The exception will then be re-raised and should be handled
    # by the caller. You don't want to charge first and then create the enrollement, b/c if
    # the charge succeeds and the enrollment fails, you are hosed.
    gc = nil
    GiftCertificate.transaction do
      gross_price, tax, extra_descrip = get_tax_info(assembly.price, discounted_price, ip_address)
      gc = GiftCertificate.create!(
              purchaser_id: purchaser.id,
              assembly_id: assembly.id,
              price: gross_price,
              sales_tax: tax,
              recipient_email: gift_info["recipientEmail"],
              recipient_name: gift_info["recipientName"],
              recipient_message: gift_info["recipientMessage"],
              email_to_recipient: gift_info["emailToRecipient"]
            )
      unless (purchaser.admin? || purchaser.role == 'collaborator')
        collect_money(assembly.price, discounted_price, assembly.title, extra_descrip, purchaser, stripe_token, existing_card)
      end
      gc.send_email(gift_info["emailToRecipient"])
    end

    gc
  end

  def self.redeem(user, id)
    gc = GiftCertificate.find(id)
    enrollment = nil
    GiftCertificate.transaction do
      gc.redeemed = true
      gc.save!
      enrollment = Enrollment.create!(user_id: user.id, enrollable: gc.assembly, gift_certificate_id: id)
    end
    enrollment
  end

  def send_email(to_recipient)
    # Little hack cuz I can't get pow to work lately
    dom = DOMAIN
    dom = "localhost:3000" if dom == "delve.dev"

    GiftCertificateMailer.recipient_email(
        to_recipient,
        User.find(purchaser_id),
        Assembly.find(assembly_id).title,
        "http://" + dom + "/gift/" + token,
        recipient_email,
        recipient_name,
        recipient_message
      ).deliver()
  end

  def resend_email(to_recipient)
    # Little hack cuz I can't get pow to work lately
    dom = DOMAIN
    dom = "localhost:3000" if dom == "delve.dev"

    GiftCertificateMailer.resend_recipient_email(
        to_recipient,
        User.find(purchaser_id),
        Assembly.find(assembly_id).title,
        "http://" + dom + "/gift/" + token,
        recipient_email,
        recipient_name,
        recipient_message
      ).deliver()

    self.followed_up = true
    self.save
  end
end
