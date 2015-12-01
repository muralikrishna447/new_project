class StripeOrder < ActiveRecord::Base
  # This is ephemeral data that is used to get the order correctly into stripe.
  attr_accessible :idempotency_key, :user_id, :data
  serialize :data, JSON
  belongs_to :user

  def stripe_order
    {
      currency: "usd",
      email: user.email,
      customer: user.stripe_id,
      items: stripe_items,
      metadata: {
        user_id: user_id,
        id: id,
        env: Rails.env
        },
      shipping: stripe_shipping
    }
  end

  def stripe_shipping
    if data['circulator_sale']
      {
        name: data['shipping_name'],
        # phone: data[:shipping_phone],
        address: {
          line1: data['shipping_address_line1'],
          city: data['shipping_address_city'],
          state: data['shipping_address_state'],
          postal_code: data['shipping_address_zip'],
          country: data['shipping_address_country']
        }
      }
    else
      {
        name: data['billing_name'],
        address: {
          line1: data['billing_address_line1'],
          city: data['billing_address_city'],
          state: data['billing_address_state'],
          postal_code: data['billing_address_zip'],
          country: data['billing_address_country']
        }
      }
    end
  end


  def stripe_items
    line_items = []
    if data['circulator_sale']
      if data['premium_discount']
        line_items << {
          amount: data['circulator_base_price'],
          currency: 'usd',
          description: 'Joule Circulator',
          parent: 'cs10001',
          quantity: 1,
          type: 'sku'
        }

        line_items << {
          amount: data['circulator_discount'].to_i*-1,
          currency: 'usd',
          description: 'ChefSteps Premium Joule Discount',
          parent: nil,
          quantity: 1,
          type: 'discount'
        }
      else
        line_items << {
          amount: data['price'],
          currency: 'usd',
          description: 'Joule Circulator',
          parent: 'cs10001',
          quantity: 1,
          type: 'sku'
        }
      end
    else
      line_items << {
        amount: data['price'],
        currency: 'usd',
        description: 'ChefSteps Premium',
        parent: 'cs10002',
        quantity: 1,
        type: 'sku'
      }
    end
    line_items
  end

  def send_to_stripe
    Rails.logger.info("Starting send_to_stripe")
    stripe_user = self.create_or_update_user

    stripe = Stripe::Order.create(self.stripe_order, {idempotency_key: self.idempotency_key})
    Rails.logger.info("Received Stripe info\n #{stripe.inspect}")

    if stripe.status != 'paid'
      Rails.logger.info("Stripe Order #{id} not paid, charging now")
      stripe_charge = stripe.pay({customer: stripe_user.id}, {idempotency_key: (self.idempotency_key+"A")})
      Rails.logger.info("Stripe Order #{id} - Stripe Charge: #{stripe_charge.inspect}")
      if stripe_charge.status == 'paid'
        Rails.logger.info("Stripe Order #{id} has been collected. Sending Analytics")
        analytics(stripe_charge)
        #mixpanel.track(user.email, 'Charge Server Side', {price: (data['price'].to_f/100.0), description: description, gift: data['gift']})
        Rails.logger.info("Stripe Order #{id} - Analytics Sent Updating user")
        self.submitted = true
        self.save
        Rails.logger.info("Stripe Order #{id} - User Updated - Sending Receipt")
        GenericReceiptMailer.prepare(self, stripe_charge).deliver rescue nil

        if data['gift']
          Rails.logger.info("Stripe Order #{id} - Sending Gift Receipt")
          pgc = PremiumGiftCertificate.create!(purchaser_id: user.id, price: data['price'], redeemed: false)
          PremiumGiftCertificateMailer.prepare(user, pgc.token).deliver rescue nil
        end

        if data['circulator_sale']
          JouleConfirmationMailer.prepare(user).deliver rescue nil
        end

      end
    end

    if ! data['gift']
      # Normally redundant
      Rails.logger.info("Stripe Order #{id} - Making Premium")
      self.user.make_premium_member(data['price'])
    end

    # Always mark a circulator sale as using the discount (because they are either buying it with premium or using their discount)
    if data['circulator_sale'] #data['premium_discount'] # This would be only to use the discount if they purchased the cheaper circulator
      Rails.logger.info("Stripe Order #{id} - Using Discount")
      user.use_premium_discount
    end
  end

  def description
    if data['circulator_sale']
      if data['premium_discount']
        "ChefSteps Joule with Premium Discount"
      else
        "ChefSteps Joule and Premium"
      end
    else
      "ChefSteps Premium"
    end
  end

  def analytics(stripe_charge)
    tax_item = stripe_charge.items.detect{|item| item.type == 'tax'}
    discount_item = stripe_charge.items.detect{|item| item.type == 'discount'}
    purchased_item = stripe_charge.items.detect{|item| item.type == 'sku'}
    Analytics.track(user_id: user_id, event: 'Completed Order',
      context: {
        'GoogleAnalytics' => {
          clientId: data['google_analytics_client_id']
        },
        campaign: {
          name: data['utm_campaign'],
          source: data['utm_source'],
          medium: data['utm_medium'],
          term: data['utm_term'],
          content: data['utm_content']
        }
      },
      referrer: {
        id: data['utm_link']
      },
      properties: {
        product_skus: [purchased_item.parent],
        orderId: stripe_charge.id,
        total: (stripe_charge.amount.to_f/100.0),
        revenue: ((stripe_charge.amount-(tax_item.try(:amount) || 0))/100.0),
        tax: ((tax_item.try(:amount) || 0)/100.0),
        shipping: 0,
        discount: ((discount_item.try(:amount) || 0)/100.0),
        discount_type: (data['premium_discount'] ? 'circulator' : nil ),
        gift: data['gift'],
        currency: 'USD',
        products: [
          {
            id: purchased_item.parent,
            sku: purchased_item.parent,
            name: purchased_item.description,
            price: (purchased_item.amount.to_f/100.0),
            quantity: 1
          }
        ]
      }
    )

  end

  def create_or_update_user
    Rails.logger.info("Stripe Order #{id} - create_or_update_user")
    customer = nil
    if user.stripe_id.blank?
      Rails.logger.info("Stripe Order #{id} - Creating new user")
      begin
        customer = Stripe::Customer.create(email: user.email, card: data['token'])
        user.stripe_id = customer.id
        user.save
      rescue Stripe::InvalidRequestError => error
        Rails.logger.info("Stripe Order #{id} - Current customer Error #{error}")
        if error.message.include?("You cannot use a Stripe token more than once")
          return customer
        else
          raise error
        end
      end
      Rails.logger.info("Stripe Order #{id} - Sent to stripe")
    else
      Rails.logger.info("Stripe Order #{id} - Current customer updating credit card")
      begin
        customer = Stripe::Customer.retrieve(user.stripe_id)
        customer.source = data['token']
        customer.save
      rescue Stripe::InvalidRequestError => error
        Rails.logger.info("Stripe Order #{id} - Current customer Error #{error}")
        if error.message.include?("You cannot use a Stripe token more than once")
          return customer
        else
          raise error
        end
      end
      Rails.logger.info("Stripe Order #{id} - Customer updated")
    end
    return customer
  end


  def self.build_stripe_order_data(params, circulator, premium)
    data = {sku: params[:sku]}
    data[:circulator_sale] = false
    data[:premium_discount] = false
    data[:gift] = data[:gift] = params[:gift] == 'true'
    data[:circulator_tax_code] = circulator[:tax_code]
    data[:premium_tax_code] = premium[:tax_code]
    data[:circulator_discount] = (circulator[:price]-circulator['premiumPrice'])
    data[:circulator_base_price] = circulator[:price]
    data[:premium_base_price] = premium[:price]
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
    data
  end

  def self.stripe_products
    products = Stripe::Product.all(active: true)
    circulator = premium = nil
    products.each do |product|
      sku = product.skus.first
      if product.id == 'cs-premium' || product.id == 'cs10002'
        premium = {sku: sku.id, title: product.name, price: sku.price, msrp: sku.metadata[:msrp].to_i, tax_code: sku.metadata[:tax_code], shippable: product.shippable}
      elsif product.id == 'cs-joule' || product.id == 'cs10001'
        circulator = {sku: sku.id, title: product.name, price: sku.price, msrp: sku.metadata[:msrp].to_i, 'premiumPrice' => sku.metadata[:premium_price].to_i, tax_code: sku.metadata[:tax_code], shippable: product.shippable}
      end
    end
    return [circulator, premium]
  end
end
