# ECOMTODO: retry failures, and handle cases where
# retry didn't work. This may need to be differentiated
# between digital and hard goods.

class StripeChargeProcessor
  @queue = :stripe_charge_processor
  def self.perform(email, token, price, description)
    customer = Stripe::Customer.create(
      email: email,
      card: token
    )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => (price.to_f * 100).to_i,
      :description => description,
      :currency    => 'usd'
    )

    mixpanel = ChefstepsMixpanel.new
    mixpanel.track(email, 'Charge Server Side', {price: price, description: description})
  end
end