require './rails_shim'
require 'csv'

# Creates a shipment confirmation TSV file to upload to Seller Central
# based on a shipments file received from Rosti.

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

  option.on('-i', '--input INPUT', 'Shipments file from Rosti') do |input|
    options[:input] = input
  end
end
option_parser.parse!
raise '--key is required' unless options[:api_key]
raise '--password is required' unless options[:password]
raise '--store is required' unless options[:store]
raise '--input is required' unless options[:input]

ShopifyAPI::Base.site = "https://#{options[:api_key]}:#{options[:password]}@#{options[:store]}.myshopify.com/admin"

rows = CSV.parse(File.open(options[:input], 'r').read, headers: true)
# This takes care of parsing the rows into Fulfillment::Shipment objects
shipments = Fulfillment::RostiShipmentImporter.to_shipments(rows)
amazon_shipments = []
# Find all the shipments for Amazon orders based on the order source name.
shipments.each do |shipment|
  if shipment.order.source_name != 'amazon-3p-fbm'
    Rails.logger.debug "Order with id #{shipment.order.id}, name #{shipment.order.name} " \
                       'is not an Amazon 3P order, skipping'
    next
  end
  amazon_shipments << shipment
end

def amazon_order_id(order)
  attrs = order.note_attributes.select { |attr| attr.name == 'amazon-order-id' }
  raise "Order with id #{order.id} has multiple amazon-order-ids" if attrs.length > 1
  raise "Order with id #{order.id} has no amazon-order-id" if attrs.empty?
  attrs.first.value
end

def amazon_order_item_id(order)
  attrs = order.note_attributes.select { |attr| attr.name == 'amazon-order-item-id' }
  raise "Order with id #{order.id} has multiple amazon-order-ids" if attrs.length > 1
  raise "Order with id #{order.id} has no amazon-order-id" if attrs.empty?
  attrs.first.value
end

# Create a TSV file in the format accepted by Seller Central.
csv_str = CSV.generate(col_sep: "\t") do |output|
  output << [
    'order-id',
    'order-item-id',
    'quantity',
    'ship-date',
    'carrier-code',
    'carrier-name',
    'tracking-number',
    'ship-method'
  ]

  Rails.logger.debug "Found #{amazon_shipments.length} Amazon order shipments to confirm"

  # We ship each item separately, so we need to generate one line
  # per tracking number where the quantity is always 1.
  amazon_shipments.each do |shipment|
    amazon_order_id = amazon_order_id(shipment.order)
    amazon_order_item_id = amazon_order_item_id(shipment.order)
    shipment.tracking_numbers.each_index do |i|
      Rails.logger.debug "Adding confirmation for Shopify order with id #{shipment.order.id}, " \
                         "name #{shipment.order.name}, Amazon order with id #{amazon_order_id}, " \
                         "item id #{amazon_order_item_id}, tracking number #{shipment.tracking_numbers[i]}"

      output << [
        amazon_order_id,
        amazon_order_item_id,
        1,
        shipment.shipped_on_dates[i].strftime('%Y-%m-%d'),
        shipment.tracking_company,
        '', # carrier-name intentionally blank per spec b/c we have carrier-code
        shipment.tracking_numbers[i],
        'FedEx International Priority DirectDistribution'
      ]
    end
  end
end

puts csv_str
