# ECOMTODO: retry failures, and handle cases where
# retry didn't work. This may need to be differentiated
# between digital and hard goods.

class StripeChargeProcessor
  @queue = :stripe_charge_processor

  def self.perform(stripe_order_id)
    Rails.logger.info("Stripe Order #{stripe_order_id} - Performing Charge")
    stripe_order = StripeOrder.find(stripe_order_id)
    Rails.logger.info("Stripe Order #{stripe_order.id} - Found Stripe Order, Sending to stripe")
    stripe_order.send_to_stripe
    Rails.logger.info("Stripe Order #{stripe_order.id} - Flushing librato metrics")
    Librato.tracker.flush
    Rails.logger.info("Stripe Order #{stripe_order_id} - DONE")
  end

end
