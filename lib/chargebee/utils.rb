require 'chargebee'

module Chargebee
  class Utils
    STUDIO_PASS_EMPLOYEE_COUPON_ID = ENV['STUDIO_PASS_EMPLOYEE_COUPON_ID']

    def self.grant_employee_subscriptions(user_id, email)
      grant_employee_subscription(user_id, email, 'chefsteps_studio_pass', STUDIO_PASS_EMPLOYEE_COUPON_ID)
    end

    # There are absolutely possibilities for timing issues here if
    # an employee subscribes separately on the site, but that seems
    # highly unlikely to happen.
    def self.grant_employee_subscription(user_id, email, plan_id, coupon_id)
      # Chargebee has different APIs to subscribe depending on whether
      # the customer already exists, so check that now.
      begin
        customer_result = ChargeBee::Customer.retrieve(user_id)
      rescue ChargeBee::InvalidRequestError
        customer_result = nil
      end

      # If the employee is already subscribed, we do nothing.
      existing_subscriptions = ChargeBee::Subscription.list(
        limit: 1,
        'plan_id[is]' => plan_id,
        'customer_id[is]' => user_id
      )
      return if existing_subscriptions.length > 0

      subscription = {
        plan_id: plan_id,
        coupon_ids: [coupon_id]
      }
      if customer_result.present?
        # Create the subscription for an existing Chargebee Customer
        ChargeBee::Subscription.create_for_customer(user_id, subscription)
      else
        # Create a new Chargebee Customer along with the subscription.
        ChargeBee::Subscription.create(
          subscription.merge(customer: { id: user_id, email: email })
        )
      end
    end
  end
end
