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

def fulfillable_line_item?(order, line_item)
  return false unless line_item
  return false if line_item.vendor != @options[:vendor]
  return false if line_item.fulfillable_quantity < 1
  order.fulfillments.each do |fulfillment|
    fulfillment.line_items.each do |fulfillment_line_item|
      next unless fulfillment_line_item.id == line_item.id
      if fulfillment.status == 'success' || fulfillment.status == 'open'
        Rails.logger.debug("Skipping order with id #{order.id} and " \
                           "fulfillment with id #{fulfillment.id} because fulfillment " \
                           "status is #{fulfillment.status}")
        return false
      end
      Rails.logger.debug("Order with id #{order.id} and fulfillment with " \
                        "id #{fulfillment.id} is fulfillable fulfillment status is #{fulfillment.status}")
      return true
    end
  end
  Rails.logger.debug("Order with id #{order.id} and line " \
                    "item with id #{line_item.id} is fulfillable because no fulfillment exists")
  true
end

def pickup_time(line_item)
  pickup_times = line_item.properties.select { |p| p.name == 'Pickup Time' || p.name == 'customizery_1' }
  raise "No Pickup Time property found for line item #{line_item.inspect}" if pickup_times.empty?
  raise "Multiple Pickup Time properties found for line item #{line_item.inspect}" if pickup_times.length > 1
  pickup_times.first.value
end

orders = Shopify::Utils.search_orders(status: 'open')
fulfillables = []
orders.each do |order|
  fulfillable_line_items = []
  order.line_items.each do |line_item|
    fulfillable_line_items << line_item if fulfillable_line_item?(order, line_item)
  end
  next if fulfillable_line_items.empty?
  fulfillables << Fulfillment::Fulfillable.new(
    order: order,
    line_items: fulfillable_line_items
  )
end

output_str = CSV.generate(force_quotes: true) do |output|
  output << [
    'Order Number',
    'Processed At',
    'Name',
    'Email',
    'Phone',
    'Product SKU',
    'Product Title',
    'Quantity',
    'Unit Price',
    'Pickup Time'
  ]

  fulfillables.each do |fulfillable|
    fulfillable.line_items.each do |line_item|
      output << [
        fulfillable.order.name,
        fulfillable.order.processed_at,
        fulfillable.order.respond_to?(:billing_address) ? fulfillable.order.billing_address.name : 'Unknown',
        fulfillable.order.respond_to?(:billing_address) ? fulfillable.order.billing_address.phone : 'Unknown',
        fulfillable.order.email,
        line_item.sku,
        line_item.name,
        line_item.fulfillable_quantity,
        line_item.price,
        pickup_time(line_item)
      ]
    end
  end
end
puts output_str
