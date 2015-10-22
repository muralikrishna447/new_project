class Circulator < ActiveRecord::Base
  has_many :circulator_users, dependent: :destroy
  has_many :users, through: :circulator_users

  attr_encrypted :secret_key, :algorithm => 'aes-256-cbc', :key => ENV["AES_KEY"]

#  has_many :actor_addresses, as: actor

  validates :notes, length: { maximum: 50 }

  include ActsAsSanitized
  sanitize_input :notes, :serial_number, :id

  attr_accessible :notes, :serial_number

end
