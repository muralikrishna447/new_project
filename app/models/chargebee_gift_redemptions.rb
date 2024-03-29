class ChargebeeGiftRedemptions < ApplicationRecord

  validates_presence_of :gift_id, :user_id, :plan_amount, :currency_code

  scope :incomplete, -> { where(:complete => false) }
  scope :complete, -> { where(:complete => true) }
end
