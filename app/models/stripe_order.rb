class StripeOrder < ActiveRecord::Base
  attr_accessible :idempotency_key, :user_id, :data
  serialize :data, JSON
  belongs_to :user

  circulator_plus_premium = 'Joule + ChefSteps Premium'
  circulator_plus_discount = 'Joule + Premium Discount'
  premium_description = 'ChefSteps Premium'

  def stripe_order
    {
      currency: "usd",
      email: user.email,
      customer: user.stripe_user_id,
      items: stripe_items,
      metadata: {
        user_id: user_id,
        id: id
        },
      shipping: stripe_shipping
    }
  end

  def stripe_shipping
    if data[:circulator_sale]
      {
        name: data[:shipping_address_name],
        # phone: data[:shipping_phone],
        address: {
          line1: data[:shipping_address_line1],
          city: data[:shipping_address_city],
          state: data[:shipping_address_state],
          postal_code: data[:shipping_address_zip],
          country: data[:shipping_address_country]
        }
      }
    end
  end


  def stripe_items
    line_items = []
    if data[:circulator_sale]
      if data[:premium_discount]
        line_items << {
          amount: data[:circulator_base_price],
          currency: 'usd',
          description: 'Joule Circulator',
          parent: 'cs10001',
          quantity: 1,
          type: 'sku'
        }

        line_items << {
          amount: data[:circulator_discount],
          currency: 'usd',
          description: 'ChefSteps Premium Joule Discount',
          parent: nil,
          quantity: 1,
          type: 'discount'
        }
      else
        line_items << {
          amount: data[:price],
          currency: 'usd',
          description: 'Joule Circulator',
          parent: 'cs10001',
          quantity: 1,
          type: 'sku'
        }
        line_items << {
          amount: 0,
          currency: 'usd',
          description: 'ChefSteps Premium',
          parent: 'cs10002',
          quantity: 1,
          type: 'sku'
        }
      end
    else
      line_items << {
        amount: data[:price,
        currency: 'usd',
        description: 'ChefSteps Premium',
        parent: 'cs10002',
        quantity: 1,
        type: 'sku'
      }
    end

    tax_amount = data[:tax_amount].present? ? data[:tax_amount] : get_tax(false)[:taxable_amount]

    # if we are taking tax add it as an item
    if tax_amount && tax_amount > 0
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
      # Document Level Elements
      # Required Request Parameters
      :CustomerCode => user_id,
      :DocDate => Time.now.to_s(:avatax),
      # Best Practice Request Parameters
      :CompanyCode => "ChefSteps",
      :Client => "ChefSteps.com",
      :DocCode => id,
      #:DetailLevel => "Diagnostic", # ECOMTODO Don't go to prod
      :DetailLevel => "Tax",
      :Commit => collected,
      :DocType => (collected ? "SalesOrder" : "SalesInvoice"),
      # Optional Request Parameters
      # :PurchaseOrderNo => "PO123456", # Figure out what to use this for
      # :ReferenceCode => "ref123456", # Figure out what to use this for
      # :PosLaneCode => "09", # Used for POS
      :CurrencyCode => "USD",
      # Address Data
      :Addresses => tax_shipping_addresses,
      # Line Data
      :Lines => tax_line_items
    }
    tax_result = tax_service.get(tax_request)

    {total_taxable: (tax_result['TotalTaxable'].to_f*100).to_i, taxable_amount: (tax_result['TotalTax'].to_f*100).to_i}
  end

  def tax_shipping_addresses
    if data[:circulator_sale]
      [{
        :AddressCode => "01",
        :Line1 => data[:shipping_address_line1],
        :City => data[:shipping_address_city],
        :Region => data[:shipping_address_state],
        :PostalCode => data[:shipping_address_zip],
        :Country => data[:shipping_address_country]
      }]
    end
  end

  def tax_line_items
    line_items = []
    if data[:circulator_sale] # Bought Circulator
      line_items << {
        # Required Parameters
        :LineNo => 1,
        :ItemCode => "cs10001",
        :Qty => 1,
        :Amount => data[:price],
        :DestinationCode => "01",
        :Description => data[:description],
        :TaxCode => data[:circulator_tax_code]
      }
    else
      line_items << {
        # Required Parameters
        :LineNo => 1,
        :ItemCode => "cs10002",
        :Qty => 1,
        :Amount => data[:price],
        :DestinationCode => "01",
        :Description => data[:description],
        :TaxCode => data[:premium_tax_code]
      }
    end
  end


  class << self
    def stripe_products
      products = Stripe::Product.all(active: true)
      circulator = premium = nil
      products.each do |product|
        sku = product.skus.first
        if product.id == 'cs-premium'
          premium = {sku: sku.id, title: product.name, price: (sku.price.to_f/100.0), msrp: (sku.metadata[:msrp].to_f/100.0), tax_code: sku.metadata[:tax_code]}
        elsif product.id == 'cs-joule'
          circulator = {sku: sku.id, title: product.name, price: (sku.price.to_f/100.0), msrp: (sku.metadata[:msrp].to_f/100.0), 'premiumPrice' => (sku.metadata[:premium_price].to_f/100.0), tax_code: sku.metadata[:tax_code]}
        end
      end
      return [circulator, premium]
    end

    def set_price_description(circulator, premium, skus, premium_discount, user)
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
end
