module Api
  module V0
    class ChargesController < BaseController
      before_filter :ensure_authorized

      def create
        # ECOMTODO: this bit is just a stub where Dan can plug in real products/orders/tax/etc.
        # Harcoded right now to accept a single sku, 1000, for Premium and get the price from global settings.
        skus = JSON.parse(params[:skus])
        raise "Invalid SKUs #{params[:skus]}" if skus != [1000]

        # ECOMTODO: this is hardcoded only to buy memberships for now; needs a robust system
        # for differentiating digital entitlements from physical products.

        # ECOMTODO: this is implemented synchronously which has the same old bug - if Stripe
        # times out we'll rollback the membership incorrectly. Probably needs a combo of
        # synchronous, optimism, and webhook.

        puts "-----"
        puts params[:stripeToken]

        User.transaction do

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

          current_user.make_premium_member()

        end

        render_api_response 200

      # If anything goes wrong and we weren't able to complete the charge, tell the frontend
      rescue Exception => e
        msg = (e.message || "(blank)")
        logger.info "Charge failed with error: " + msg
        logger.info "Backtrace: "
        e.backtrace.take(20).each { |x| logger.debug x}
        render_api_response 422, { error: msg}
      end
    end
  end
end