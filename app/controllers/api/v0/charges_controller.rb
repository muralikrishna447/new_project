module Api
  module V0
    class ChargesController < BaseController
      before_filter :ensure_authorized

      def create

        @user = User.find @user_id_from_token
        # Doing this so we can call the actual charge stuff multiple times if needs be to collect the money
        circulator, premium = StripeOrder.stripe_products
        idempotency_key = Time.now.to_f.to_s+rand(10000)
        data = {sku: params[:sku]}
        data[:circulator_sale] = false
        data[:premium_discount] = false
        data[:gift] = params[:gift]
        data[:circulator_tax_code] = circulator.metadata[:tax_code]
        data[:premium_tax_code] = premium.metadata[:tax_code]
        data[:circulator_discount] = (circulator[:price]-circulator.metadata['premiumPrice'])
        data[:circulator_base_price] = circulator[:price]
        data[:premium_base_price] = premium[:price]
        if params[:sku] == "cs10001" # Circulator
          if @user.premium_member
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
          data[:price] = circulator[:price]
          data[:description] = 'ChefSteps Premium'
          data[:premium_discount] = false
          data[:circulator_sale] = false
        end

        raise "Price Mismatch" if price != params[:price]

        price = data[:price]+(params[:tax].to_f*100)


        data.merge({
          billing_address_line1: params[:billing_address_line1],
          billing_address_city: params[:billing_address_city],
          billing_address_state: params[:billing_address_state],
          billing_address_zip: params[:billing_address_zip],
          billing_address_country: params[:billing_address_country],
          shipping_address_line1: params[:shipping_address_line1],
          shipping_address_city: params[:shipping_address_city],
          shipping_address_state: params[:shipping_address_state],
          shipping_address_zip: params[:shipping_address_zip],
          shipping_address_country: params[:shipping_address_country],
          token: parmas['stripeToken']
        })

        mixpanel = ChefstepsMixpanel.new
        mixpanel.track(email, 'Charge Server Side', {price: price, description: description})

        stripe_order = StripeOrder.create({idempotency_key: idempotency_key, user_id: @user.id, data: data})

        Resque.enqueue(StripeChargeProcessor, stripe_order.id)

        if @user.stripe_id.blank?
          customer = Stripe::Customer.create(email: @user.email, card: data[:token])
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

        @user.make_premium_member(data[:premium_base_price])

        render_api_response 200

      rescue Exception => e
        puts e.inspect
        msg = (e.message || "(blank)")
        render_api_response 422, { error: msg}
      end
    end
  end
end
