class ChargesController < ApplicationController

  respond_to :json

  def create
    # TODO: this bit is just a stub where Dan can plug in real products/orders/tax/etc.
    # Harcoded right now to accept a single sku, 1000, for Premium and get the price from global settings.
    raise "Invalid SKUs #{params[:skus]}" if params[:skus] != [1000]

    customer = Stripe::Customer.create(
      email: current_user.email,
      card: params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => Setting.last.premium_membership_price.to_i * 100,
      :description => 'ChefSteps Premium',
      :currency    => 'usd'
    )

    render json: { status: 200, message: 'Success'}, status: 200

  # If anything goes wrong and we weren't able to complete the charge, tell the frontend
  rescue Exception => e
    msg = (e.message || "(blank)")
    logger.info "Charge failed with error: " + msg
    logger.info "Backtrace: "
    e.backtrace.take(20).each { |x| logger.debug x}
    render json: { errors: [msg]}, status: 422
  end

end