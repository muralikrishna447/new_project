class Circulator < ActiveRecord::Base
  has_many :circulator_users, dependent: :destroy
  has_many :users, through: :circulator_users

  validates :notes, length: { maximum: 50 }

  include ActsAsSanitized
  sanitize_input :notes, :serial_number

  attr_accessible :notes, :serial_number

end