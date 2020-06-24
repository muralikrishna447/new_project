class Circulator < ApplicationRecord
  acts_as_paranoid
  has_many :circulator_users, dependent: :destroy
  has_many :users, through: :circulator_users

  # Key generated using - Base64.encode64(OpenSSL::Random.random_bytes(24))
  attr_encrypted :secret_key, :algorithm => 'aes-256-cbc', :key => ENV["AES_KEY"], insecure_mode: true, mode: :single_iv_and_salt

#  has_many :actor_addresses, as: actor

  validates :notes, length: { maximum: 200 }
  validates :name, length: { maximum: 200 }

  include ActsAsSanitized
  sanitize_input :notes, :serial_number, :id

  after_destroy :revoke_address


  def premium_offer_eligible?
    is_15_ss = (self.hardware_version == "JA") && (!self.hardware_options.nil?) && ((self.hardware_options & 1) > 0)
    is_first_activation = !Circulator.with_deleted.where(:serial_number => self.serial_number).where('id != ?', self.id).exists?
    is_eligible = is_15_ss && is_first_activation

    Rails.logger.info("circulator.premium_offer_eligible? - is_eligible=#{is_eligible} id=#{self.id} hardware_version=#{self.hardware_version} hardware_options=#{self.hardware_options} is_first_activation=#{is_first_activation}")

    is_eligible
  end

  private
  def revoke_address
    addresses = ActorAddress.where(actor_type: 'Circulator', actor_id: self.id)
    addresses.each do |aa|
      logger.info "Revoking address #{aa.address_id} [#{aa.inspect}]"
      aa.revoke
    end
  end

end
