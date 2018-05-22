require './rails_shim'
require 'csv'

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

  option.on('-v', '--vendor VENDOR', 'Vendor') do |vendor|
    @options[:vendor] = vendor
  end
end
option_parser.parse!
raise '--key is required' unless @options[:api_key]
raise '--password is required' unless @options[:password]
raise '--store is required' unless @options[:store]
raise '--vendor is required' unless @options[:vendor]

ShopifyAPI::Base.site = "https://#{@options[:api_key]}:#{@options[:password]}@#{@options[:store]}.myshopify.com/admin"

puts Fulfillment::MarketplaceOrderExporter.generate_csv_output(
  vendor: @options[:vendor]
)
