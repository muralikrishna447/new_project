require './rails_shim'
require '../../app/models/shopify/order'
require 'csv'

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

joule_variant_id = 36413625031
joule_variant_id = 20034822983 if options[:store] == 'delve'

CSV.foreach(options[:input], col_sep: "\t", headers: true) do |row|
  Rails.logger.debug "Processing Amazon order with id #{row['order-id']}"

  # For now we only handle flagship Joule SKUs
  if row['sku'].downcase != Shopify::Order::JOULE_SKU
    raise "Amazon order with id #{row['order-id']} has unknown sku #{row['sku']}"
  end

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

  order = ShopifyAPI::Order.create(
    send_receipt: false,
    send_fulfillment_receipt: false,
    line_items: [
      {
        variant_id: joule_variant_id,
        quantity: row['quantity-to-ship'].to_i
      }
    ],
    financial_status: 'paid',
    # TODO we should add the buyer's email address at some point,
    # but not for now as it will cause shipment notification emails
    # to be sent.
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
      }
    ],
    tags: 'amazon-3p-fbm'
  )

  Rails.logger.debug "Created Shopify order with id #{order.id} for Amazon order with id #{row['order-id']}"
end
