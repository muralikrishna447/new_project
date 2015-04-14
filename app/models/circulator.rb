class Circulator < ActiveRecord::Base
  has_many :circulator_users, dependent: :destroy
  has_many :users, through: :circulator_users

  include ActsAsSanitized
  sanitize_input :notes, :serialNumber

  attr_accessible :notes, :serialNumber

end
