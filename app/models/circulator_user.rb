class CirculatorUser < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :circulator
  belongs_to :user

  attr_accessible :owner, :user, :circulator

  after_save :create_referral_code
  def create_referral_code
    if self.owner && ! self.user.referral_code
      Resque.enqueue(CreateReferralCode, self.user.id)
    end
  end

  def self.find_by_circulator_and_user(circulator, user)
    CirculatorUser.where(circulator_id: circulator.id, user_id: user).first
  end
end
