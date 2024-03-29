require 'shopify_api'
require '../../lib/shopify/utils'

#
#
#
# Options:
#   --key: Your Shopify API key
#   --password: Your Shopify API key password
#   --store: The name of the Shopify store ('delve' for prod, or 'chefsteps-staging')
#   --input: The input CSV file generated by the 'export_shopify_orders' script.
#

# Options parsing
@options = {}
option_parser = OptionParser.new do |option|
  option.on('-k', '--key API_KEY', 'Shopify API key') do |api_key|
    @options[:api_key] = api_key
  end

  option.on('-p', '--password PASSWORD', 'Shopify password') do |password|
    @options[:password] = password
  end

  option.on('-s', '--store STORE', 'Shopify store name') do |store|
    @options[:store] = store
  end

  option.on('-i', '--input FILE', 'Input file of Shopify order IDs') do |file|
    @options[:input] = file
  end

  option.on('-t', '--tag TAG', 'Tag to add') do |tag|
    @options[:tag] = tag
  end
end

option_parser.parse!
raise '--key is required' unless @options[:api_key]
raise '--password is required' unless @options[:password]
raise '--store is required' unless @options[:store]
raise '--input is required' unless @options[:input]
raise '--tag is required' unless @options[:tag]

# Configure shopify client
ShopifyAPI::Base.site = "https://#{@options[:api_key]}:#{@options[:password]}@#{@options[:store]}.myshopify.com/admin"

order_count = 0
STDERR.puts "Will add tag #{@options[:tag]}"
File.readlines(@options[:input]).each do |order_id|
  order_id.strip!

  order = ShopifyAPI::Order.find(order_id)
  Shopify::Utils.add_to_order_tags(order, [@options[:tag]])
  order.save
  STDERR.puts "Added tag to order with id #{order.id}"

  order_count += 1
end

STDERR.puts "Added tag #{@options[:tag]} to #{order_count} orders"
