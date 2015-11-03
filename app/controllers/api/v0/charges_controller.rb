module Api
  module V0
    class ChargesController < BaseController
      before_filter :ensure_authorized

      def create
        if !['cs10001', 'cs10002'].include?(params[:sku])
          #return render(json: "Not valid product", code: 422)
          return render_api_response 422, { error: "Not valid product"}
        end

        @user = User.find @user_id_from_token
        # Doing this so we can call the actual charge stuff multiple times if needs be to collect the money
        circulator, premium = StripeOrder.stripe_products
        idempotency_key = Time.now.to_f.to_s+request.ip.to_s
        data = {sku: params[:sku]}
        data[:circulator_sale] = false
        data[:premium_discount] = false
        data[:gift] = params[:gift]
        data[:circulator_tax_code] = circulator[:tax_code]
        data[:premium_tax_code] = premium[:tax_code]
        data[:circulator_discount] = (circulator[:price]-circulator['premiumPrice'])
        data[:circulator_base_price] = circulator[:price]
        data[:premium_base_price] = premium[:price]
        if params[:sku] == "cs10001" # Circulator
          if @user.premium_member && !@user.used_circulator_discount
            data[:price] = circulator['premiumPrice']
            data[:description] = 'Joule + Premium Discount'
            data[:premium_discount] = true
            data[:circulator_sale] = true
          else
            data[:price] = circulator[:price]
            data[:description] = 'Joule + ChefSteps Premium'
            data[:premium_discount] = false
            data[:circulator_sale] = true
          end
        elsif params[:sku] == 'cs10002' # Premium
          data[:price] = premium[:price]
          data[:description] = 'ChefSteps Premium'
          data[:premium_discount] = false
          data[:circulator_sale] = false
        end

        if !params[:gift] && params[:sku] == 'cs10002' && @user.premium_member
          #raise "User Already Premium"
          return render_api_response 422, { error: "User Already Premium"}
        end

        if data[:price].to_i != params[:price].to_i
          #raise "Price Mismatch #{data[:price]} - #{(params[:price].to_f*100).to_i}"
          return render_api_response 422, { error: "Price Mismatch #{data[:price]} - #{params[:price]}"}
        end

        if params[:tax]
          price = data[:price].to_i+params[:tax].to_i
        else
          price = data[:price].to_i
        end

        data.merge!({
          billing_name: params[:billing_name],
          billing_address_line1: params[:billing_address_line1],
          billing_address_city: params[:billing_address_city],
          billing_address_state: params[:billing_address_state],
          billing_address_zip: params[:billing_address_zip],
          billing_address_country: params[:billing_address_country],
          shipping_name: params[:shipping_name],
          shipping_address_line1: params[:shipping_address_line1],
          shipping_address_city: params[:shipping_address_city],
          shipping_address_state: params[:shipping_address_state],
          shipping_address_zip: params[:shipping_address_zip],
          shipping_address_country: params[:shipping_address_country],
          token: params['stripeToken']
        })

        mixpanel = ChefstepsMixpanel.new
        mixpanel.track(@user.email, 'Charge Server Side', {price: price, description: data[:description]})

        stripe_order = StripeOrder.create({idempotency_key: idempotency_key, user_id: @user.id, data: data})

        Resque.enqueue(StripeChargeProcessor, stripe_order.id)

        stripe_order.send_to_stripe

        render_api_response 200

      rescue StandardError => e
        puts e.inspect
        msg = (e.message || "(blank)")
        logger.error("ChargesController#create error: #{e.message}\n#{e.backtrace.join("\n")}")
        render_api_response 422, { error: 'Something went wrong, please try again'}
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
