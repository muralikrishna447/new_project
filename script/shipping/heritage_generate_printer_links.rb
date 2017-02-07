require './rails_shim'
require 'csv'
require 'set'

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
  option.on('-i', '--input INPUT', 'Input file') do |input|
    options[:input] = input
  end
end
option_parser.parse!
raise '--key is required' unless options[:api_key]
raise '--password is required' unless options[:password]
raise '--store is required' unless options[:store]
raise '--input is required' unless options[:input]

ShopifyAPI::Base.site = "https://#{options[:api_key]}:#{options[:password]}@#{options[:store]}.myshopify.com/admin"

order_ids_by_pickup_time = {}
CSV.foreach(options[:input], headers: true) do |row|
  order_number = row['Order Number']
  pickup_time = row['Pickup Time']

  Rails.logger.debug("Looking up order number #{order_number}")
  order = Shopify::Utils.order_by_name(order_number)
  raise "No order with number #{order_number}" unless order
  order_ids_by_pickup_time[pickup_time] ||= Set.new
  order_ids_by_pickup_time[pickup_time] << order.id
end

output_str = CSV.generate(force_quotes: true) do |output|
  output << ['Pickup Time', 'Order Printer URL']

  order_ids_by_pickup_time.each do |pickup_time, order_id_list|
    url = "https://#{options[:store]}.myshopify.com/admin/apps/order-printer/orders/bulk?shop=#{options[:store]}.myshopify.com"
    order_id_list.each do |order_id|
      url.concat("&ids[]=#{order_id}")
    end
    output << [pickup_time, url]
  end
end
puts output_str
