require 'chargebee'

module Subscriptions
  class ChargebeeUtils
    STUDIO_PASS_EMPLOYEE_COUPON_ID = ENV['STUDIO_PASS_EMPLOYEE_COUPON_ID']

    def self.grant_employee_subscriptions(user_id, email)
      create_subscription(user_id, email, Subscription::STUDIO_PLAN_ID, STUDIO_PASS_EMPLOYEE_COUPON_ID)
    end

    # The method first checks if the user has an active subscription matching the provided plan_id
    # If it does then it bails out and does nothing else
    #
    # This method does not prevent race conditions if it's called multiple times at the same time
    #
    # There are absolutely possibilities for timing issues here if
    # a user happens to create a  subscribe separately on the site,
    # but that seems highly unlikely to happen."
    def self.create_subscription(user_id, email, plan_id, coupon_id)
      # If the employee is already subscribed, we do nothing.
      existing_subscriptions = ChargeBee::Subscription.list(
        limit: 1,
        'status[in]' => Subscription::ACTIVE_PLAN_STATUSES,
        'plan_id[is]' => plan_id,
        'customer_id[is]' => user_id
      )
      return if existing_subscriptions.length > 0

      # Chargebee has different APIs to subscribe depending on whether
      # the customer already exists, so check that now.
      begin
        customer_result = ChargeBee::Customer.retrieve(user_id)
      rescue ChargeBee::InvalidRequestError
        customer_result = nil
      end

      subscription = {
        plan_id: plan_id,
      }
      if coupon_id.present?
        subscription[:coupon_ids] = [coupon_id]
      end

      if customer_result.present?
        # Create the subscription for an existing Chargebee Customer
        response = ChargeBee::Subscription.create_for_customer(user_id, subscription)
      else
        # Create a new Chargebee Customer along with the subscription.
        response = ChargeBee::Subscription.create(
          subscription.merge(customer: { id: user_id, email: email })
        )
      end

      params = {
        plan_id: plan_id,
        status: response.subscription.status,
        resource_version: response.subscription.resource_version
      }
      Subscription.create_or_update_by_params(params, user_id)
    end
  end
end
