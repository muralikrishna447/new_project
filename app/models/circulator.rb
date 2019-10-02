class Circulator < ActiveRecord::Base
  acts_as_paranoid
  has_many :circulator_users, dependent: :destroy
  has_many :users, through: :circulator_users

  # Key generated using - Base64.encode64(OpenSSL::Random.random_bytes(24))
  attr_encrypted :secret_key, :algorithm => 'aes-256-cbc', :key => ENV["AES_KEY"]

#  has_many :actor_addresses, as: actor

  validates :notes, length: { maximum: 200 }
  validates :name, length: { maximum: 200 }
  

  include ActsAsSanitized
  sanitize_input :notes, :serial_number, :id

  attr_accessible :notes, :serial_number

  after_create :redeem_new_circulator_offers
  after_destroy :revoke_address


  private
  def revoke_address
    addresses = ActorAddress.where(actor_type: 'Circulator', actor_id: self.id)
    addresses.each do |aa|
      logger.info "Revoking address #{aa.address_id} [#{aa.inspect}]"
      aa.revoke
    end
  end

  def redeem_new_circulator_offers
    if premium_offer_eligible?
      user = self.circulator_users.first
      price = 0
      Rails.logger.info("redeem_new_circulator_offers - premium eligible - id=#{self.id} hardware_version=#{self.hardware_version} hardware_options=#{self.hardware_options} user.present?=#{user.present?}")
      if user
        Rails.logger.info("redeem_new_circulator_offers - making user premium - user.id=#{user.id}")
        user.make_premium_member(price)
      end
    else
      Rails.logger.info("redeem_new_circulator_offers - not premium eligible - id=#{self.id} hardware_version=#{self.hardware_version} hardware_options=#{self.hardware_options}")
    end
  end

  def premium_offer_eligible?
    # 1.5 SS Joules
    (self.hardware_version == "JA") && ((self.hardware_options & 1) > 0)
  end
end
