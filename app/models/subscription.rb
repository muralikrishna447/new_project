class Subscription < ActiveRecord::Base
  # TODO - do we want to use environment variable for the Plan ID?
  PREMIUM_PLAN_ID = ENV['PREMIUM_PLAN_ID'] || 'cbdemo_nuts'

  belongs_to :user

  attr_accessible :plan_id
  attr_accessible :status

  validates :status, inclusion: { in: %w(future in_trial active non_renewing paused cancelled) }

  scope :active, where(:status => ['active', 'in_trial', 'non_renewing'])

  def self.user_has_subscription?(user, plan_id)
    self.where(:user_id => user.id).where(:plan_id => plan_id).active
  end

  def self.user_has_premium?(user)
    self.user_has_subscription?(user, PREMIUM_PLAN_ID)
  end

end
