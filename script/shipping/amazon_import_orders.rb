require './rails_shim'
require '../../app/models/shopify/order'
require 'csv'
require 'peddler'
require 'bigdecimal'

options = {}
option_parser = OptionParser.new do |option|
  option.on('-k', '--key API_KEY', 'Shopify API key') do |api_key|
    options[:api_key] = api_key
  end

  option.on('-p', '--password PASSWORD', 'Shopify password') do |password|
    options[:password] = password
  end

  option.on('-s', '--store STORE', 'Shopify store name') do |store|
    options[:store] = store
  end

  option.on('-i', '--input INPUT', 'Amazon unshipped order report from Seller Central') do |input|
    options[:input] = input
  end
end
option_parser.parse!
raise '--key is required' unless options[:api_key]
raise '--password is required' unless options[:password]
raise '--store is required' unless options[:store]
raise '--input is required' unless options[:input]

ShopifyAPI::Base.site = "https://#{options[:api_key]}:#{options[:password]}@#{options[:store]}.myshopify.com/admin"
@mws_client = MWS::Orders::Client.new

@joule_variant_id = 36413625031
@joule_variant_id = 20034822983 if options[:store] == 'delve'

# Retrieves a line item for an Amazon order via MWS API
def amazon_order_item(order_id, order_item_id)
  response = @mws_client.list_order_items(order_id).parse
  items = response.fetch('OrderItems')
  # Currently we only expect one item to be in here. It will need to be
  # more fancy later to handle multiple SKUs.
  raise "Amazon order with id #{order_id} has more than one order item: #{items.inspect}" if items.length > 1
  raise "Amazon order with id #{order_id} has no order items" if items.empty?

  item = items.fetch('OrderItem')
  if item.fetch('SellerSKU').downcase != Shopify::Order::JOULE_SKU
    raise "Amazon order with id #{order_id} has unknown sku: #{item.inspect}"
  end
  if item.fetch('OrderItemId') != order_item_id
    raise "Amazon order with id #{order_id} has unknown order item id, " \
          "expected #{order_item_id} but got #{item.fetch('OrderItemId')}"
  end
  item
end

# Extracts the price of an Amazon line item from an MWS response
def amazon_item_price(item)
  item_price = item.fetch('ItemPrice')
  if item_price.fetch('CurrencyCode') != 'USD'
    raise "Amazon order with id #{order_id} item price has unknown currency code: #{item_price.inspect}"
  end
  BigDecimal.new(item_price.fetch('Amount'))
end

# Extracts the tax amount of an Amazon line item from an MWS response
def amazon_item_tax(item)
  item_tax = item.fetch('ItemTax')
  if item_tax.fetch('CurrencyCode') != 'USD'
    raise "Amazon order with id #{order_id} item tax has unknown currency code: #{item_tax.inspect}"
  end
  BigDecimal.new(item_tax.fetch('Amount'))
end

def create_shopify_order(row, price_amount, tax_amount)
  address2 = [row['ship-address-2'], row['ship-address-3']].reject{ |line| line.nil? || line.empty? }.join(' ').strip

  phone = row['buyer-phone-number']
  phone = '(206) 905-1099' if phone.nil? || phone.empty?

  shipping_address = {
    name: row['recipient-name'],
    address1: row['ship-address-1'],
    address2: address2,
    city: row['ship-city'],
    province_code: row['ship-state'],
    country_code: row['ship-country'],
    # We don't have the recipient's phone number, so use the buyer.
    phone: phone,
    zip: row['ship-postal-code']
  }
  # Some orders have the two-character state abbreviation, some have the full name.
  # Decide what to do based on the length of the state and Shopify will figure
  # it all out from there.
  if row['ship-state'].length == 2
    shipping_address[:province_code] = row['ship-state']
  else
    shipping_address[:province] = row['ship-state']
  end

  quantity = row['quantity-to-ship'].to_i

  ShopifyAPI::Order.create(
    send_receipt: false,
    send_fulfillment_receipt: false,
    line_items: [
      {
        variant_id: @joule_variant_id,
        quantity: quantity,
        # The item price from amazon is the unit price multiplied by the
        # quantity, so we divide it here to get the Shopify line item price.
        price: (price_amount / quantity).to_s,
        tax_lines: [
          {
            price: tax_amount.to_s,
            # MWS does not provide a tax rate so we do the calculation here.
            rate: (tax_amount / price_amount).to_s
          }
        ]
      }
    ],
    # You would think this value would be derived, but we must set it directly
    # or Shopify will not include tax amounts in the order total.
    total_tax: tax_amount.to_s,
    financial_status: 'paid',
    shipping_address: shipping_address,
    source_name: 'amazon-3p-fbm',
    note_attributes: [
      {
        name: 'amazon-order-id',
        value: row['order-id']
      },
      {
        name: 'amazon-order-item-id',
        value: row['order-item-id']
      },
      {
        name: 'amazon-buyer-email',
        value: row['buyer-email']
      }
    ],
    tags: 'amazon-3p-fbm'
  )
end

CSV.foreach(options[:input], col_sep: "\t", headers: true) do |row|
  Rails.logger.debug "Processing Amazon order with id #{row['order-id']}"

  # For now we only handle flagship Joule SKUs
  if row['sku'].downcase != Shopify::Order::JOULE_SKU
    raise "Amazon order with id #{amazon_order_id} has unknown sku #{row['sku']}"
  end

  item = amazon_order_item(row['order-id'], row['order-item-id'])
  price_amount = amazon_item_price(item)
  tax_amount = amazon_item_tax(item)
  Rails.logger.debug "Amazon order with id #{row['order-id']} has item with " \
                     "price #{price_amount}, tax #{tax_amount}"

  order = create_shopify_order(row, price_amount, tax_amount)
  # It's totally possible that we can get addresses from Amazon
  # that are invalid according to our rules. Run the validator
  # right after creating the order so we can grep the standard
  # error output from this script and correct any problems.
  Fulfillment::ShippingAddressValidator.validate(order)
  Rails.logger.debug "Created Shopify order with id #{order.id} for Amazon order with id #{row['order-id']}"
end
