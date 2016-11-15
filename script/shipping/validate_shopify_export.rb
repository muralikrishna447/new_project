require 'csv'
require 'optparse'
require 'shopify_api'
require 'lob'
require 'json'
require 'pry'
require './shipping'

#
# Validates a Shopify CSV export generated by the 'export_shopify_orders' script.
# The script will validate orders according to issues that are known to cause
# import failures in Shipwire. It will also verify addresses if desired.
#
# The output of this script is a filtered list of CSV input rows that are deemed
# to be valid.
#
# Options:
#   --input: The input CSV file generated by the 'export_shopify_orders' script.
#   --verify-addresses: Specify if you want to verify addresses.
#   --lob-key: The Lob.com API key to use if using --verify-addresses.
#   --error-output: CSV file to output validation errors to, if you want.
#

# FedEx address lines are limited to 35 characters
MAX_ADDRESS_LENGTH = 35

# Options parsing
@options = {}
option_parser = OptionParser.new do |option|
  option.on('-i', '--input FILE', 'CSV input file of Shopify orders') do |file|
    @options[:file] = file
  end

  option.on('-l', '--lob-key LOB_API_KEY', 'Lob API key to use when verifying addresses') do |lob_key|
    @options[:lob_key] = lob_key
  end

  option.on('-a', '--verify-addresses', 'Whether to verify addresses') do
    @options[:verify_addresses] = true
  end

  option.on('-e', '--error-output ERROR_OUTPUT', 'File to send error output to') do |file|
    @options[:error_output] = file
  end
end

option_parser.parse!
raise '--input is required' unless @options[:file]
if @options[:verify_addresses] && !@options[:lob_key]
  raise '--lob_key is required when specifying --verify_addresses'
end

# Configure Lob address verification client
if @options[:verify_addresses]
  Lob.api_key = @options[:lob_key]
  @lob = Lob.load
end

def address_verifies?(input_row)
  begin
    retries ||= 0

    @lob.addresses.verify(
      address_line1: input_row['shipping_address_1'],
      address_line2: input_row['shipping_address_2'],
      address_city: input_row['shipping_city'],
      address_state: input_row['shipping_province'],
      address_zip: input_row['shipping_zip'],
      address_country: input_row['shipping_country']
    )
  rescue Lob::InvalidRequestError => e
    error = JSON.parse(e.json_body)
    return false if error.fetch('error').fetch('message') == 'address not found'
    raise "Unexpected error from address verification API: #{e.inspect}"
  rescue Lob::LobError => e
    sleep(1)
    retry if (retries += 1) < 5
    raise e
  end
  true
end

if @options[:error_output]
  error_output_schema = Shipping::SHOPIFY_EXPORT_SCHEMA.dup
  error_output_schema << 'validation_errors'
  error_output_schema << 'order_url'
  error_output = File.open(@options[:error_output], 'w')
  error_output << "#{error_output_schema.join(',')}\n"
end

filtered_order_rows = []
valid_order_count = 0
invalid_order_count = 0
CSV.foreach(@options[:file], headers: true) do |input_row|
  order_validation_tags = []

  shipping_address_1 = input_row['shipping_address_1']
  # Some orders have no shipping address
  shipping_address_missing = false
  if shipping_address_1.nil? || shipping_address_1.empty?
    shipping_address_missing = true
    order_validation_tags << 'address-1-missing'
  end
  # Shipwire limits address lines to 50 chars
  if shipping_address_1 && shipping_address_1.length > MAX_ADDRESS_LENGTH
    order_validation_tags << 'address-1-too-long'
  end

  # Shipwire limits address lines to 50 chars
  shipping_address_2 = input_row['shipping_address_2']
  if shipping_address_2 && shipping_address_2.length > MAX_ADDRESS_LENGTH
    order_validation_tags << 'address-2-too-long'
  end

  order_validation_tags << 'name-missing' if input_row['shipping_name'].empty?

  # Verify the address using Lob API
  if @options[:verify_addresses] && !shipping_address_missing
    unless address_verifies?(input_row)
      order_validation_tags << 'address-unverifiable'
    end
  end

  if order_validation_tags.empty?
    STDERR.puts "Order with id #{input_row['id']} is valid"
    filtered_order_rows << input_row
    valid_order_count += 1
  else
    STDERR.puts "Filtering order with id #{input_row['id']} with validation errors: #{order_validation_tags}"
    input_row << order_validation_tags.join(',')
    input_row << "https://delve.myshopify.com/admin/orders/#{input_row['id']}"
    error_output << input_row if @options[:error_output]
    invalid_order_count += 1
  end
end
STDERR.puts "Found #{valid_order_count} valid orders and filtered #{invalid_order_count} invalid orders"

output_str = CSV.generate(force_quotes: true) do |output_rows|
  output_rows << Shipping::SHOPIFY_EXPORT_SCHEMA
  filtered_order_rows.each { |row| output_rows << row }
end
puts output_str

error_output.close if @options[:error_output]