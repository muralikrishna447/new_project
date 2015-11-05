module Api
  module V0
    class ChargesController < BaseController
      before_filter :ensure_authorized

      def create
        @user = User.find @user_id_from_token

        # ECOMTODO: this bit is just a stub where Dan can plug in real products/orders/tax/etc.
        # Harcoded right now to accept a single sku, cs10002, for Premium and get the price from global settings.
        raise "Invalid sku #{params[:sku]}" if params[:sku] != 'cs10002'

        # ECOMTODO: this is hardcoded only to buy memberships for now; needs a robust system
        # for differentiating digital entitlements from physical products.

        # ECOMTODO: since this has already gone through stripe.js which validates the card, we go ahead
        # and give them premium right away which is a smoother, faster experience on the frontend, and
        # queue up the charge which can take a little while.

        if params[:gift] == "true"
          PremiumGiftCertificate.create!(purchaser_id: @user.id, price: Setting.last.premium_membership_price, redeemed: false)
        else
          @user.make_premium_member(Setting.last.premium_membership_price)
          PremiumWelcomeMailer.prepare(@user).deliver
        end

        Resque.enqueue(StripeChargeProcessor, @user.email, params[:stripeToken], Setting.last.premium_membership_price, params[:gift], 'ChefSteps Premium')

        render_api_response 200

      rescue StandardError => e
        puts e.inspect
        msg = (e.message || "(blank)")
        logger.error("ChargesController#create error: #{e.message}")
        render_api_response 422, { error: msg}
      end

      def redeem
        puts 'Redeem'
        @user = User.find @user_id_from_token
        PremiumGiftCertificate.redeem(@user, params[:id])
        render_api_response 200
      rescue StandardError => e
        puts e.inspect
        msg = (e.message || "(blank)")
        logger.error("ChargesController#redeem error: #{e.message}")
        render_api_response 422, { error: msg}
      end
    end
  end
end