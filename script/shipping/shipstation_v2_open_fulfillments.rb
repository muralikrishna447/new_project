require './rails_shim'

#
# Exports Shopify Joule orders using the API to a CSV on standard output.
# Options:
#   --key: Your Shopify API key
#   --password: Your Shopify API key password
#   --store: The name of the Shopify store ('delve' for prod, or 'chefsteps-staging')
#   --sku: The SKU to open fulfillments for
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

  option.on('-i', '--sku SKU', 'SKU to export') do |sku|
    options[:sku] = sku
  end

  option.on('-q', '--quantity QUANTITY', 'Quantity to export') do |quantity|
    options[:quantity] = quantity.to_i
  end
end
option_parser.parse!
raise '--key is required' unless options[:api_key]
raise '--password is required' unless options[:password]
raise '--store is required' unless options[:store]
raise '--input is required' unless options[:input]
raise '--sku is required' unless options[:sku]
raise '--quantity is required' unless options[:quantity]

# Configure shopify client
ShopifyAPI::Base.site = "https://#{options[:api_key]}:#{options[:password]}@#{options[:store]}.myshopify.com/admin"

Fulfillment::ShipstationOrderSubmitter.perform(
  storage: 'stdout',
  skus: [options[:sku]],
  search_params: {
    storage: 'file',
    storage_filename: options[:input]
  },
  open_fulfillment: options[:open_fulfillment],
  quantity: options[:quantity]
)
