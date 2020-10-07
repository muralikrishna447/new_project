class Subscription < ApplicationRecord
  STUDIO_PLAN_ID = ENV['STUDIO_PLAN_ID'] || 'chefsteps_studio_pass'
  MONTHLY_STUDIO_PLAN_ID = ENV['MONTHLY_STUDIO_PLAN_ID'] || 'chefsteps_studio_pass_monthly'
  EXISTING_PREMIUM_COUPON = ENV['EXISTING_PREMIUM_COUPON']
  ACTIVE_PLAN_STATUSES = ['active', 'in_trial', 'non_renewing']
  ONLY_ACTIVE_PLAN_STATUSES = %w[active in_trial]
  ACTIVE_OR_CANCELLED_PLAN_STATUSES = Array.new(ACTIVE_PLAN_STATUSES).concat(['cancelled'])
  CANCELLED_STATUS = ['cancelled']

  IS_STUDIO_LIVE = ENV['CS_IS_STUDIO_LIVE'] == 'true'

  belongs_to :user

  validates :status, inclusion: { in: %w(future in_trial active non_renewing paused cancelled) }

  scope :active, -> { where(:status => ACTIVE_PLAN_STATUSES) }
  scope :cancelled, -> { where(:status => CANCELLED_STATUS) }

  def self.user_has_subscription?(user, plan_id)
    self.where(:user_id => user.id).where(:plan_id => plan_id).active.exists?
  end

  def self.user_has_cancelled_subscription?(user, plan_id)
    self.where(user_id: user.id, plan_id: plan_id).cancelled.exists?
  end

  def self.user_has_studio?(user)
    self.user_has_subscription?(user, [STUDIO_PLAN_ID, MONTHLY_STUDIO_PLAN_ID])
  end

  def self.user_has_cancelled_studio?(user)
    self.user_has_cancelled_subscription?(user, [STUDIO_PLAN_ID, MONTHLY_STUDIO_PLAN_ID])
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
      #resource_version will be uniq for each request from chargebee.
      #It should be updated everytime.
      subscription.resource_version = params[:resource_version]
      subscription.status = params[:status]
    end

    subscription.save!
    subscription
  end

  def is_yearly_studio?
    plan_id == STUDIO_PLAN_ID
  end

  def is_monthly_studio?
    plan_id == MONTHLY_STUDIO_PLAN_ID
  end

  def self.duration(plan_id = nil)
    types = {
      'Monthly' => MONTHLY_STUDIO_PLAN_ID,
      'Annual' => STUDIO_PLAN_ID
    }
    plan_id ? types.invert[plan_id] : types
  end

  def plan_type
    Subscription.duration(plan_id)
  end

  def is_active
    ACTIVE_PLAN_STATUSES.include?(self.status)
  end

  after_commit :on => [:create, :update] do
    Resque.enqueue(Forum, 'update_user', Rails.application.config.shared_config[:bloom][:api_endpoint], user_id)
  end
end
