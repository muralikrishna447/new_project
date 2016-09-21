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
#   --verify-addresses: Specify if you want to verify addresses.
#   --lob-key: The Lob.com API key to use if using --verify-addresses.
#   --error-output: CSV file to output validation errors to, if you want.
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

raise '--lob-key is required with --verify-addresses' if options[:verify_addresses] && !options[:lob_key]

unless options[:dry_run]
  raise '--key is required' unless options[:key]
  raise '--password is required' unless options[:password]
  raise '--store is required' unless options[:store]
  STDERR.puts 'NOTE: --dry-run was specified, not really updating Shopify'
end

# Configure shopify client
ShopifyAPI::Base.site = "https://#{options[:api_key]}:#{options[:password]}@#{options[:store]}.myshopify.com/admin"

CSV.foreach(options[:input_file], headers: true) do |input_row|
  order_id = input_row['orderId (S)']
  address_1 = input_row['address1 (S)']
  address_2 = input_row['address2 (NULL)']
  city = input_row['city (S)']
  province = input_row['province (S)']
  zip = input_row['zip (S)']

  STDERR.puts "Updading order with id #{order_id} with data #{input_row}"

  unless options[:dry_run]
    order = ShopifyAPI::Order.find(order_id)
    raise "Unknown order #{order_id}" unless order

    order.shipping_address.attributes[:address1] = address_1
    if address_2 && address_2 != 'true' # Column has value true if not specified
      order.shipping_address.attributes[:address2] = address_2
    else
      order.shipping_address.attributes[:address2] = nil
    end
    order.shipping_address.attributes[:city] = city
    order.shipping_address.attributes[:province_code] = province
    order.shipping_address.attributes[:zip] = zip

    order.save
  end
end
