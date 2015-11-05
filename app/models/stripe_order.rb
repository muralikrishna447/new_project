class StripeOrder < ActiveRecord::Base
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
        id: id
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
    stripe_user = self.create_or_update_user

    stripe = Stripe::Order.create(self.stripe_order, {idempotency_key: self.idempotency_key})
    stripe_charge = stripe.pay({customer: stripe_user.id}, {idempotency_key: (self.idempotency_key+"A")})
    if stripe_charge.status == 'paid'
      self.submitted = true
      self.save
    end

    if data['gift']
      PremiumGiftCertificate.create!(purchaser_id: user.id, price: data['price'], redeemed: false)
    else
      if !self.user.premium_member
        self.user.make_premium_member(data['price'])
      else
        raise "Should never get here"
      end
    end

    if data['premium_discount']
      user.use_premium_discount
    end
  end

  def create_or_update_user
    customer = nil
    if user.stripe_id.blank?
      customer = Stripe::Customer.create(email: user.email, card: data['token'])
      user.stripe_id = customer.id
      user.save
    else
      customer = Stripe::Customer.retrieve(user.stripe_id)
      customer.source = data['token']
      customer.save
    end
    return customer
  end


  def self.build_stripe_order_data(params, circulator, premium)
    data = {sku: params[:sku]}
    data[:circulator_sale] = false
    data[:premium_discount] = false
    data[:gift] = params[:gift]
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
      if product.id == 'cs-premium'
        premium = {sku: sku.id, title: product.name, price: sku.price, msrp: sku.metadata[:msrp].to_i, tax_code: sku.metadata[:tax_code], shippable: product.shippable}
      elsif product.id == 'cs-joule'
        circulator = {sku: sku.id, title: product.name, price: sku.price, msrp: sku.metadata[:msrp].to_i, 'premiumPrice' => sku.metadata[:premium_price].to_i, tax_code: sku.metadata[:tax_code], shippable: product.shippable}
      end
    end
    return [circulator, premium]
  end

  def self.set_price_description(circulator, premium, skus, premium_discount, user)
    price = description = nil

    if skus.include?(circulator[:sku])
      if premium_discount # Switch this to something else?
        description = circulator_plus_discount
        price = circulator['premiumPrice']
      else
        description = circulator_plus_premium
        price = circulator[:price]
      end
    end

    if skus.include?(premium[:sku])
      description = premium_description
      price = premium[:price]
    end
    return [price, description]
  end
end
