require './rails_shim'

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

  option.on('-o', '--open-fulfillment', 'Open fulfillment') do
    options[:open_fulfillment] = true
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

# Configure shopify client
ShopifyAPI::Base.site = "https://#{options[:api_key]}:#{options[:password]}@#{options[:store]}.myshopify.com/admin"

orders = []
CSV.foreach(options[:input], headers: true) do |input_row|
  order = ShopifyAPI::Order.find(input_row['id'])
  raise "No order for id input_row['id']" unless order
  orders << order
end

fulfillables = Fulfillment::ShipstationOrderExporter.fulfillables(orders, ['cs10001'])
if options[:open_fulfillment]
  Fulfillment::ShipstationOrderExporter.open_fulfillments(fulfillables)
end
