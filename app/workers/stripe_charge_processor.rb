# ECOMTODO: retry failures, and handle cases where
# retry didn't work. This may need to be differentiated
# between digital and hard goods.

class StripeChargeProcessor
  @queue = :stripe_charge_processor

  def self.perform(stripe_order_id)
    stripe_order = StripeOrder.find(stripe_order_id)
    stripe_order.send_to_stripe
  end

end
