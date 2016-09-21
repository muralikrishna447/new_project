require 'csv'
require 'optparse'
require 'shopify_api'
require 'pry'
require './shipping'

#
# Exports Shopify Joule orders using the API to a CSV on standard output.
# Options:
#   --key: Your Shopify API key
#   --password: Your Shopify API key password
#   --store: The name of the Shopify store ('delve' for prod, or 'chefsteps-staging')
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
end
option_parser.parse!
raise '--key is required' unless options[:api_key]
raise '--password is required' unless options[:password]
raise '--store is required' unless options[:store]

# Configure shopify client
ShopifyAPI::Base.site = "https://#{options[:api_key]}:#{options[:password]}@#{options[:store]}.myshopify.com/admin"

# Helper methods
def joule_line_item(order)
  line_items = order.line_items.select { |item| item.sku == 'cs10001' }
  line_items.first
end

def shipping_address_prop(order, prop)
  # The method doesn't exist on orders with no shipping address
  order.shipping_address.send(prop) if order.respond_to?(:shipping_address)
end

def shipping_name(order)
  first_name = shipping_address_prop(order, :first_name)
  last_name = shipping_address_prop(order, :last_name)
  if first_name && last_name
    "#{first_name} #{last_name}"
  elsif first_name
    first_name
  elsif last_name
    last_name
  end
end

# Retrieve orders from shopify API and export to CSV
PAGE_SIZE = 100
order_count = 0
page = 1
all_orders = []
loop do
  STDERR.puts "Fetching order page #{page}"
  path = ShopifyAPI::Order.collection_path(
    status: 'open',
    fulfillment_status: 'unshipped',
    limit: PAGE_SIZE,
    page: page
  )
  orders = ShopifyAPI::Order.find(:all, from: path)
  orders.each do |order|
    # We only care about Joules
    joule_line_item = joule_line_item(order)
    next unless joule_line_item

    all_orders << [
      order.id,
      order.name,
      DateTime.parse(order.processed_at),
      shipping_name(order),
      shipping_address_prop(order, :address1),
      shipping_address_prop(order, :address2),
      shipping_address_prop(order, :city),
      shipping_address_prop(order, :province_code),
      shipping_address_prop(order, :zip),
      shipping_address_prop(order, :country_code),
      order.email,
      shipping_address_prop(order, :phone),
      joule_line_item.sku,
      joule_line_item.quantity,
      order.tags
    ]

    order_count += 1
  end
  break if orders.length < PAGE_SIZE
  page += 1
end

all_orders.sort! do |x, y|
  x[Shipping::SHOPIFY_EXPORT_SCHEMA_PROCESSED_AT_COLUMN] <=> y[Shipping::SHOPIFY_EXPORT_SCHEMA_PROCESSED_AT_COLUMN]
end
all_orders.each_index do |i|
  all_orders[i][Shipping::SHOPIFY_EXPORT_SCHEMA_PROCESSED_AT_INDEX_COMLUMN] = i + 1
end

output_str = CSV.generate(force_quotes: true) do |output_rows|
  # CSV header
  output_rows << Shipping::SHOPIFY_EXPORT_SCHEMA

  all_orders.each { |order| output_rows << order }
end

STDERR.puts "Exported #{order_count} orders"
puts output_str
