# ECOMTODO: retry failures, and handle cases where
# retry didn't work. This may need to be differentiated
# between digital and hard goods.

class StripeChargeProcessor
  @queue = :stripe_charge_processor

  def self.perform(stripe_order_id)
    stripe_order = StripeOrder.find(stripe_order_id)
    if stripe_order.user.stripe_id.blank?
      customer = Stripe::Customer.create(email: @user.email, card: data[:token])
      stripe_order.user.stripe_id = customer.id
    else
      customer = Stripe::Customer.retrieve(@user.stripe_id)
      customer.source = data[:token]
      customer.save
    end
    stripe_order.data[:tax_amount] = stripe_order.get_tax(false)[:taxable_amount]
    stripe_order.save
    Stripe::Order.create(stripe_order.stripe_order)
    stripe_order.submitted = true
    stripe_order.save
    stripe_order.user.make_premium_member(stripe_order.data[:premium_base_price])
  end

end
