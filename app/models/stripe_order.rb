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
        name: data['shipping_address_name'],
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
          amount: data['circulator_discount'],
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
        line_items << {
          amount: '0',
          currency: 'usd',
          description: 'ChefSteps Premium',
          parent: 'cs10002',
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

    tax_amount = data['tax_amount'].present? ? data['tax_amount'] : get_tax(false)[:taxable_amount]

    # if we are taking tax add it as an item
    if tax_amount && tax_amount.to_i > 0
      line_items << {
        amount: tax_amount,
        currency: 'usd',
        description: "Sales Tax",
        parent: nil,
        quantity: nil,
        type: 'tax'
      }
    end

    line_items
  end


  def get_tax(collected=false)
    tax_service = AvaTax::TaxService.new
    tax_request = {
      :CustomerCode => user_id,
      :DocDate => Time.now.to_s(:avatax),
      :CompanyCode => "ChefSteps",
      :Client => "ChefSteps.com",
      :DocCode => id,
      #:DetailLevel => "Diagnostic", # ECOMTODO Don't go to prod
      :DetailLevel => "Tax",
      :Commit => collected,
      :DocType => (collected ? "SalesOrder" : "SalesInvoice"),
      :CurrencyCode => "USD",
      :Addresses => tax_shipping_addresses,
      :Lines => tax_line_items
    }
    tax_result = tax_service.get(tax_request)

    {total_taxable: (tax_result['TotalTaxable'].to_f*100).to_i, taxable_amount: (tax_result['TotalTax'].to_f*100).to_i}
  end

  def tax_shipping_addresses
    if data['circulator_sale']
      [{
        :AddressCode => "01",
        :Line1 => data['shipping_address_line1'],
        :City => data['shipping_address_city'],
        :Region => data['shipping_address_state'],
        :PostalCode => data['shipping_address_zip'],
        :Country => data['shipping_address_country']
      }]
    end
  end

  def tax_line_items
    line_items = []
    if data['circulator_sale'] # Bought Circulator
      line_items << {
        # Required Parameters
        :LineNo => 1,
        :ItemCode => "cs10001",
        :Qty => 1,
        :Amount => data['price'],
        :DestinationCode => "01",
        :Description => data['description'],
        :TaxCode => data['circulator_tax_code']
      }
    else
      line_items << {
        # Required Parameters
        :LineNo => 1,
        :ItemCode => "cs10002",
        :Qty => 1,
        :Amount => data['price'],
        :DestinationCode => "01",
        :Description => data['description'],
        :TaxCode => data['premium_tax_code']
      }
    end
  end

  def send_to_stripe
    self.create_or_update_user

    self.data['tax_amount'] = self.get_tax(false)['taxable_amount']

    self.save

    stripe = Stripe::Order.create(self.stripe_order, {idempotency_key: self.idempotency_key})
    stripe_charge = stripe.pay({source: data['token']}, {idempotency_key: (self.idempotency_key+"A")})
    if stripe_charge.status == 'paid'
      self.submitted = true
      self.save
    end

    if data['gift']
      PremiumGiftCertificate.create!(purchaser_id: user.id, price: data['price'], redeemed: false)
    else
      user.make_premium_member(data['price']) if !user.premium_member && !data['gift']
    end
    user.update_attribute(:used_ciruclator_discount, true) if data['premium_discount']
  end

  def create_or_update_user
    if user.stripe_id.blank?
      customer = Stripe::Customer.create(email: user.email, card: data['token'])
    else
      customer = Stripe::Customer.retrieve(user.stripe_id)
      customer.source = data['token']
      customer.save
    end
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
