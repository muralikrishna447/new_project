class ChargebeeGiftRedemptions < ActiveRecord::Base
  attr_accessible :gift_id, :complete, :user_id, :plan_amount, :currency_code
  validates_presence_of :gift_id, :user_id, :plan_amount, :currency_code

  scope :incomplete, where(:complete => false)
end
