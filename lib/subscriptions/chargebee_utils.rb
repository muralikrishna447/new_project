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
        'status[in]' => Subscription::ACTIVE_OR_CANCELLED_PLAN_STATUSES,
        'plan_id[is]' => plan_id,
        'customer_id[is]' => user_id
      )

      should_create_subscription = existing_subscriptions.length == 0

      if should_create_subscription
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
      else
        response = existing_subscriptions.first

        handle_cancelled_subscription(response.subscription, response.customer)
        handle_non_renewing_subscription(response.subscription, response.customer)
      end

      nil
    end

    def self.calculate_new_term_end(subscription, promotional_credits)
      extra_periods = (promotional_credits / subscription.plan_amount).floor
      current_term_end = Time.at(subscription.current_term_end)

      case subscription.billing_period_unit
      when "year"
        extra = extra_periods.year
      when 'month'
        extra = extra_periods.month
      else
        raise NotImplementedError.new("calculate_new_term_end received unsupported billing_period_unit=#{subscription.billing_period_unit} subscription.id=#{subscription.id}")
      end

      new_term_end = current_term_end + extra
      new_term_end.to_i
    end

    private

    # If the subscription is cancelled and the user has promotional credits then remove the cancellation
    def self.handle_cancelled_subscription(subscription, customer)
      if subscription.status == 'cancelled' && customer.promotional_credits > 0
        Rails.logger.info("create_subscription - reactivating cancelled subscription.id=#{subscription.id} belonging to customer.id=#{customer.id} has promotional credits=#{customer.promotional_credits}")
        ChargeBee::Subscription.reactivate(subscription.id,{
            :invoice_immediately => true,
            :billing_cycles => 1 # handle_non_renewing_subscription will extend the term date to whatever is
        })
      end
    end

    # If the subscription is non-renewing and the user has promotional credits then we need to extend the term end
    def self.handle_non_renewing_subscription(subscription, customer)
      if subscription.status == 'non_renewing' && customer.promotional_credits > 0
        Rails.logger.info("create_subscription - extending non_renewing subscription.id=#{subscription.id} belonging to customer.id=#{customer.id} has promotional credits=#{customer.promotional_credits}")
        new_term_ends_at = calculate_new_term_end(subscription, customer.promotional_credits)
        if new_term_ends_at != subscription.current_term_end
          Rails.logger.info("create_subscription - setting terms_ends_at to=#{new_term_ends_at}")
          ChargeBee::Subscription.change_term_end(subscription.id,{
              :term_ends_at => new_term_ends_at
          })
        end
      end
    end
  end
end
