require 'shopify_api'
require 'lob'
require 'csv'
require 'pry'

#
# Updates shipping addresses in Shopify by order ID based on the
# "verify your address" email data stored in Dynamo. This script
# expects a CSV export from Dynaamo.
#
# The output of this script is a filtered list of CSV input rows that are deemed
# to be valid.
#
# Options:
#   --key: Your Shopify API key
#   --password: Your Shopify API key password
#   --store: The name of the Shopify store ('delve' for prod, or 'chefsteps-staging')
#   --dry-run: Do a dry run and don't actually update the Shopify order.
#   --input: Input CSV file that was exported from Dynamo.
#

# Options parsing
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

  option.on('-d', '--dry-run', 'Do a dry run and do not update Shopify') do
    options[:dry_run] = true
  end

  option.on('-i', '--input INPUT_FILE', 'Input file') do |input_file|
    options[:input_file] = input_file
  end
end
option_parser.parse!

unless options[:dry_run]
  raise '--key is required' unless options[:api_key]
  raise '--password is required' unless options[:password]
  raise '--store is required' unless options[:store]
  STDERR.puts 'NOTE: --dry-run was specified, not really updating Shopify'
end

def joule_fulfillment(shopify_order)
  joule_fulfillments = []
  shopify_order.fulfillments.each do |fulfillment|
    fulfillment.line_items.each do |line_item|
      joule_fulfillments << fulfillment if line_item.sku == 'cs10001'
    end
  end
  if joule_fulfillments.length > 1
    raise "Multiple Joule fulfillments exist for Shopify order with id #{shopify_order.id}, expected only one: #{joule_fulfillments.inspect}"
  end
  # Return the fulfillment, or nil if none exists
  joule_fulfillments.first
end

# Configure shopify client
ShopifyAPI::Base.site = "https://#{options[:api_key]}:#{options[:password]}@#{options[:store]}.myshopify.com/admin"

CSV.foreach(options[:input_file], headers: true) do |input_row|
  order_id = input_row['orderId (S)']
  address_1 = input_row['address1 (S)']
  address_2 = input_row['address2 (S)']
  city = input_row['city (S)']
  province = input_row['province (S)']
  zip = input_row['zip (S)']

  order = ShopifyAPI::Order.find(order_id)
  raise "Unknown order #{order_id}" unless order

  joule_fulfillment = joule_fulfillment(order)
  if joule_fulfillment && joule_fulfillment.status == 'success'
    STDERR.puts "Order with id #{order.id} has already been fulfilled, not updating address"
  else
    order.shipping_address.attributes[:address1] = address_1
    if address_2 && address_2 != 'true' # Column has value true if not specified
      order.shipping_address.attributes[:address2] = address_2
    else
      order.shipping_address.attributes[:address2] = nil
    end
    order.shipping_address.attributes[:city] = city
    order.shipping_address.attributes[:province_code] = province
    order.shipping_address.attributes[:zip] = zip

    if address_1.length > 35
      STDERR.puts "WARNING: Address1 line is too long for order with id #{order.id}"
    end
    if address_2.length > 35
      STDERR.puts "WARNING: Address2 line is too long for order with id #{order.id}"
    end

    STDERR.puts "Updading order with id #{order_id} with data #{order.shipping_address.inspect}"

    order.save unless options[:dry_run]
  end
end
