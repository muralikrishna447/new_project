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
      user.make_premium_member(price)
    end
  end

  def premium_offer_eligible?
    # TODO - how to identify 1.5 SS Joules
    self.hardware_version = "foo" && self.hardware_options = "bar"
  end
end
