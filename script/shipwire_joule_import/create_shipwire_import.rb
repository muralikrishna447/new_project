require 'csv'
require 'optparse'
require 'date'

#
# Takes a CSV from the output of the 'sort_shopify_orders' script and
# sorts it (in FIFO order of placement).
#
# The output of this script is the sorted CSV input.
#
# Options:
#   --file: The input CSV file generated by the 'sort_shopify_orders' script.
#

# Options parsing
options = {}
option_parser = OptionParser.new do |option|
  option.on('-f', '--file FILE', 'CSV export file of Shopify orders') do |file|
    options[:file] = file
  end
end

option_parser.parse!
raise '--file is required' unless options[:file]

shipwire_orders = []
CSV.foreach(options[:file], headers: true) do |shopify_order|
  # Shipwire requires a shipping phone number, as all carriers require this.
  # We aren't currently capturing this from customers.
  shipping_phone = shopify_order['shipping_phone']
  if shipping_phone.nil? || shipping_phone.empty?
    # This is our catch-all Google voice number that no one answers but can leave a message.
    shipping_phone = '206-905-1099'
  end

  shipwire_orders << [
    "#{shopify_order['name']}.1", # Order number, in the same (strange) format that the Shipwire/Shopify app sends it
    shopify_order['id'], # External order ID
    DateTime.parse(shopify_order['processed_at']).to_date.to_s,
    shopify_order['shipping_name'],
    shopify_order['shipping_address_1'],
    shopify_order['shipping_address_2'],
    nil, # Address line 3, which we don't have
    shopify_order['shipping_city'],
    shopify_order['shipping_province'],
    shopify_order['shipping_zip'],
    shopify_order['shipping_country'],
    shopify_order['email'],
    shipping_phone,
    nil, # Shipping method, leave blank for cheapest option
    nil, # Commercial address boolean, which we don't know but Shipwire will guess for us
    shopify_order['sku'],
    shopify_order['quantity'],
    nil, # Company name, leave blank to use value set on the ShipWire account
    nil, # Order hold boolean
    nil, # Order hold reason
  ]
end

output_str = CSV.generate(force_quotes: true) do |output|
  output << [
    '[order_no]',
    '[external_id]',
    '[order_date]',
    '[name]',
    '[address_1]',
    '[address_2]',
    '[address_3]',
    '[city]',
    '[state]',
    '[zip]',
    '[country]',
    '[email]',
    '[phone]',
    '[shipping_method]',
    '[is_commercial]',
    '[sku]',
    '[quantity]',
    '[company_name]',
    '[hold]',
    '[hold_reason]'
  ]
  shipwire_orders.each { |shipwire_order| output << shipwire_order }
end

puts output_str

STDERR.puts "Created Shipwire CSV import with #{shipwire_orders.length} orders"
