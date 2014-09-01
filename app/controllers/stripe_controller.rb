class StripeController < ApplicationController
  def current_customer
    if current_user
      customer = Stripe::Customer.retrieve(current_user.stripe_id)
      render json: customer
    end
  end
end