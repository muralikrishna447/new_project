require 'csv'
require 'optparse'
require 'shopify_api'
require 'pry'
require '../../lib/shopify/utils'

#
# Takes a shipment CSV export from ShipStation and updates Shopify's
# fulfillment state and tracking numbers for each shipped order.
#
# Options:
#   --input: The ShipStation shipment export.
#   --key: Your Shopify API key
#   --password: Your Shopify API key password
#   --store: The name of the Shopify store ('delve' for prod, or 'chefsteps-staging')
#   --dry-run: Don't actually update Shopify
#

# Options parsing
options = {}
option_parser = OptionParser.new do |option|
  option.on('-i', '--input INPUT_FILE', 'ShipStation shipment export CSV file') do |file|
    options[:input] = file
  end

  option.on('-k', '--key API_KEY', 'Shopify API key') do |api_key|
    options[:api_key] = api_key
  end

  option.on('-p', '--password PASSWORD', 'Shopify password') do |password|
    options[:password] = password
  end

  option.on('-s', '--store STORE', 'Shopify store name') do |store|
    options[:store] = store
  end

  option.on('-d', '--dry-run', 'Do not update Shopify') do
    options[:dry_run] = true
  end
end
option_parser.parse!
raise '--input is required' unless options[:input]
raise '--key is required' unless options[:api_key]
raise '--password is required' unless options[:password]
raise '--store is required' unless options[:store]

# Configure shopify client
ShopifyAPI::Base.site = "https://#{options[:api_key]}:#{options[:password]}@#{options[:store]}.myshopify.com/admin"

# Helpers
def joule_line_item(shopify_order)
  joule_line_items = []
  shopify_order.line_items.each do |line_item|
    joule_line_items << line_item if line_item.sku == 'cs10001'
  end
  if joule_line_items.length > 1
    raise "Order with id #{shopify_order.id} has multiple Joule line items, expected only one"
  elsif joule_line_items.empty?
    raise "Order with id #{shopify_order.id} contains no Joule line item"
  end
  joule_line_items.first
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

order_count = 0
fulfilled_count = 0
CSV.foreach(options[:input], headers: true) do |shipment|
  order_number = shipment['Order - Number'].delete('#')
  tracking_number = shipment['Shipment - Tracking Number']
  carrier = shipment['Shipment - Carrier']

  path = ShopifyAPI::Order.collection_path(name: order_number)
  orders = ShopifyAPI::Order.find(:all, from: path)
  raise "Order with number #{order_number} does not exist" if orders.empty?
  raise "More than one order with number #{order_number}, expected only one" if orders.length > 1

  order = orders.first
  STDERR.puts "Found order with id #{order.id} for order number #{order_number}"

  if joule_fulfillment(order)
    STDERR.puts "Order with id #{order.id} and number #{order_number} already has a Joule fulfillment, skipping it"
  else
    STDERR.puts "Creating fulfillment for order with id #{order.id}, number #{order_number}, and tracking #{tracking_number}"
    fulfillment = ShopifyAPI::Fulfillment.new
    fulfillment.prefix_options[:order_id] = order.id
    fulfillment.attributes[:line_items] = [{ id: joule_line_item(order).id }]
    fulfillment.attributes[:tracking_company] = carrier
    fulfillment.attributes[:tracking_number] = tracking_number
    fulfillment.save unless options[:dry_run]
    fulfilled_count += 1
  end

  Shopify::Utils.remove_from_order_tags(order, ['shipping-started'])
  order.save unless options[:dry_run]
  STDERR.puts "Removed 'shipping-started' tag for order with id #{order.id} and number #{order_number}"

  order_count += 1
end

STDERR.puts "Processed shipments for #{order_count} orders, completed #{fulfilled_count} fulfillments"
