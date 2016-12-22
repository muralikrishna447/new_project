class Tf2Redemption < ActiveRecord::Base
  belongs_to :user

  validates_uniqueness_of :redemption_code

  scope :not_redeemed, -> { where(user_id: nil) }

  def self.redeem!(user)
    redemption = Tf2Redemption.not_redeemed.first
    if redemption
      redemption.redeemed_at = Time.now
      redemption.user_id = user.id
      result = redemption.save
      Rails.logger.info "Redeemed #{redemption.id} to #{user.id}"
      result
    else
      Rails.logger.error "Error - No More Redemption Codes"
      raise "Error - No More Redemption Codes"
    end
  end
end
