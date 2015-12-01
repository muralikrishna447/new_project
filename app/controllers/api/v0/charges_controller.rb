module Api
  module V0
    class ChargesController < BaseController
      before_filter :ensure_authorized

      def google_analytics_client_id
        google_analytics_cookie.gsub(/^GA\d\.\d\./, '')
      end

      def google_analytics_cookie
        cookies['_ga'] || ''
      end

      def set_analytics_parameters(data)
        # Setup utm_ variables so that we can add them to our analytics calls to segment
        begin
          if cookies[:utm].present?
            Rails.logger.info "ChargesController#create - Parsing utm cookie.  #{cookies[:utm]}"
            utm_cookie = JSON.parse(cookies[:utm])
            utm_cookie.each_pair do |k,v|
              data[k] = v
            end
          end
          data[:google_analytics_client_id] = google_analytics_client_id
        rescue => e
          Rails.logger.error "Something went wrong with the cookie parser #{e}"
        end
      end

      def create
        return render_api_response 500, { error: "Not valid product"} if !['cs10001', 'cs10002'].include?(params[:sku])

        @user = User.find @user_id_from_token

        idempotency_key = Time.now.to_f.to_s+request.ip.to_s
        circulator, premium = StripeOrder.stripe_products
        data = StripeOrder.build_stripe_order_data(params, circulator, premium)

        set_analytics_parameters(data)

        gift = (params[:gift] == "true")

        if params[:sku] == "cs10001" # Circulator
          if @user.can_receive_circulator_discount?
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

        if data[:circulator_sale] && data[:shipping_address_country] != "United States"
          return render_api_response 500, { error: "Unfortunately Joule  isn't available in your country yet, but we're working to change that. Email us to get updates on availability"}
        end

        if !gift && params[:sku] == 'cs10002' && @user.premium_member
          #raise "User Already Premium"
          return render_api_response 500, { error: "User Already Premium"}
        end

        if data[:price].to_i > params[:price].to_i
          #raise "Price Mismatch #{data[:price]} - #{(params[:price].to_f*100).to_i}"
          return render_api_response 500, { error: "Price Mismatch"}
        end

        if params[:tax]
          price = data[:price].to_i+params[:tax].to_i
        else
          price = data[:price].to_i
        end

        stripe_order = StripeOrder.create({idempotency_key: idempotency_key, user_id: @user.id, data: data})

        if !gift && !@user.premium?
          @user.make_premium_member(premium[:price])
          PremiumWelcomeMailer.prepare(@user, data[:circulator_sale]).deliver rescue nil
        end

        Resque.enqueue(StripeChargeProcessor, stripe_order.id)

        # stripe_order.send_to_stripe


        # Mark all circulator sales as using the premium discount because they are either buying their first one at the discount or buying it with premium
        if data[:circulator_sale] # data[:premium_discount]
          @user.use_premium_discount
        end

        render_api_response 200

      rescue StandardError => e
        msg = (e.message || "(Something Went Wrong)")
        logger.error("ChargesController#create error: #{e.message}\n#{e.backtrace.join("\n")}")
        render_api_response 500, { error: msg }
      end

      def redeem
        logger.info('Redeem gift cert #{params[:id]}')
        @user = User.find @user_id_from_token
        PremiumGiftCertificate.redeem(@user, params[:id])
        PremiumWelcomeMailer.prepare(@user).deliver
        render_api_response 200
      rescue StandardError => e
        puts e.inspect
        msg = (e.message || "(blank)")
        logger.error("ChargesController#redeem error: #{e.message}")
        render_api_response 500, { error: msg}
      end
    end
  end
end
