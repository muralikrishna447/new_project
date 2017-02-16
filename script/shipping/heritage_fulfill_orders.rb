require './rails_shim'
require 'csv'
require 'pry'

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
  option.on('-i', '--input INPUT', 'Input file') do |input|
    options[:input] = input
  end
end
option_parser.parse!
raise '--key is required' unless options[:api_key]
raise '--password is required' unless options[:password]
raise '--store is required' unless options[:store]
raise '--input is required' unless options[:input]

ShopifyAPI::Base.site = "https://#{options[:api_key]}:#{options[:password]}@#{options[:store]}.myshopify.com/admin"

def heritage_line_items(order)
  order.line_items.select { |line_item| line_item.vendor == 'Heritage Meats' }
end

CSV.foreach(options[:input], headers: true) do |row|
  order_number = row['Order Number']
  Rails.logger.debug("Completing fulfillment for order number #{order_number}")
  order = Shopify::Utils.order_by_name(order_number)
  raise "No order with number #{order_number}" unless order
  fulfillment = ShopifyAPI::Fulfillment.new
  fulfillment.prefix_options[:order_id] = order.id
  fulfillment.attributes[:line_items] = heritage_line_items(order).map do |line_item|
    { id: line_item.id, quantity: line_item.fulfillable_quantity }
  end
  fulfillment.attributes[:notify_customer] = false
  Shopify::Utils.send_assert_true(fulfillment, :save)
end
