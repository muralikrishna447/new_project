require './rails_shim'
require '../../app/models/shopify/order'

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

  option.on('-q', '--quantity QUANTITY', 'Quantity to export') do |store|
    options[:quantity] = store
  end
end
option_parser.parse!
raise '--key is required' unless options[:api_key]
raise '--password is required' unless options[:password]
raise '--store is required' unless options[:store]
raise '--input is required' unless options[:input]
raise '--quantity is required' unless options[:quantity]

# Configure shopify client
ShopifyAPI::Base.site = "https://#{options[:api_key]}:#{options[:password]}@#{options[:store]}.myshopify.com/admin"

Fulfillment::RostiOrderSubmitter.perform(
  storage: 'stdout',
  skus: [Shopify::Order::JOULE_SKU],
  search_params: {
    storage: 'file',
    storage_filename: options[:input]
  },
  open_fulfillment: options[:open_fulfillment],
  quantity: options[:quantity].to_i
)
