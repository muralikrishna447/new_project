class Subscription < ActiveRecord::Base
  STUDIO_PLAN_ID = ENV['STUDIO_PLAN_ID']
  EXISTING_PREMIUM_COUPON = ENV['EXISTING_PREMIUM_COUPON']
  ACTIVE_PLAN_STATUSES = ['active', 'in_trial', 'non_renewing']

  IS_STUDIO_LIVE = ENV['CS_IS_STUDIO_LIVE'] == 'true'

  belongs_to :user

  attr_accessible :plan_id
  attr_accessible :status

  # For the webhook, to handle out of order messages
  # https://www.chargebee.com/docs/webhook_settings.html
  attr_accessible :resource_version

  validates :status, inclusion: { in: %w(future in_trial active non_renewing paused cancelled) }

  scope :active, where(:status => ACTIVE_PLAN_STATUSES)

  def self.user_has_subscription?(user, plan_id)
    self.where(:user_id => user.id).where(:plan_id => plan_id).active.exists?
  end

  def self.user_has_studio?(user)
    self.user_has_subscription?(user, STUDIO_PLAN_ID)
  end

  def self.create_or_update_by_params(params, user_id)
    attributes = { :plan_id => params[:plan_id], :user_id => user_id }

    begin
      subscription = self.where(attributes).first_or_create! do |sub|
        sub.user_id = user_id
        sub.plan_id = params[:plan_id]
        sub.status = params[:status]
        sub.resource_version = params[:resource_version]
      end
    rescue ActiveRecord::RecordNotUnique
      subscription = self.where(attributes).first!
    end

    if params[:resource_version].to_i > subscription.resource_version
      subscription.status = params[:status]
    end

    subscription.save!
    subscription
  end

  def is_active
    ACTIVE_PLAN_STATUSES.include?(self.status)
  end

end