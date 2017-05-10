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

fulfillables = []
Shopify::Utils.search_orders_with_each(status: 'open') do |order|
  fulfillable_line_items = []
  order.line_items.each do |line_item|
    if Fulfillment::MarketplaceUtils.fulfillable_line_item?(order, line_item, @options[:vendor])
      fulfillable_line_items << line_item
    end
  end
  next if fulfillable_line_items.empty?
  fulfillables << Fulfillment::Fulfillable.new(
    order: order,
    line_items: fulfillable_line_items
  )
end

output_str = CSV.generate(force_quotes: true) do |output|
  header_row = [
    'Order Number',
    'Processed At',
    'Name',
    'Email',
    'Phone',
    'Product SKU',
    'Product Title',
    'Variant',
    'Quantity',
    'Unit Price',
    'Fulfillment Details',
    'Delivery Address'
  ]
  # Add a column indicating whether the customer opted in, but only
  # if the vendor has SMS reminders available.
  sms_reminders_available = false
  if Fulfillment::MarketplaceUtils.sms_reminders_available?(@options[:vendor])
    Rails.logger.debug("Vendor #{@options[:vendor]} has SMS reminders available, will add to export")
    sms_reminders_available = true
    header_row << 'SMS Opted In'
  else
    Rails.logger.debug("Vendor #{@options[:vendor]} does not have SMS reminders available, not adding to export")
  end
  output << header_row

  fulfillables.each do |fulfillable|
    name = fulfillable.order.shipping_address.name if fulfillable.order.respond_to?(:shipping_address)
    name ||= fulfillable.order.billing_address.name if fulfillable.order.respond_to?(:billing_address)
    name ||= 'Unknown'

    phone = fulfillable.order.shipping_address.phone if fulfillable.order.respond_to?(:shipping_address)
    phone ||= fulfillable.order.billing_address.phone if fulfillable.order.respond_to?(:billing_address)
    phone ||= 'Unknown'

    fulfillable.line_items.each do |line_item|
      delivery_address = ''
      if Fulfillment::MarketplaceUtils.delivery?(line_item)
        fulfillment_details = Fulfillment::MarketplaceUtils.delivery_details(line_item)
        if fulfillable.order.respond_to?(:shipping_address)
          a = fulfillable.order.shipping_address
          delivery_address = "#{a.address1} #{a.address2} #{a.company} #{a.city} #{a.province_code} #{a.zip}"
        end
      else
        fulfillment_details = Fulfillment::MarketplaceUtils.pickup_details(line_item)
      end

      unless fulfillment_details
        Rails.logger.warn "No fulfillment details found for order with id #{fulfillable.order.id} " \
                          "and line item with id #{line_item.id}"
      end

      line_item_row = [
        fulfillable.order.name,
        DateTime.parse(fulfillable.order.processed_at).strftime('%m/%d/%Y %H:%M:%S'),
        name,
        fulfillable.order.email,
        phone,
        line_item.sku,
        line_item.title,
        line_item.variant_title,
        line_item.fulfillable_quantity,
        line_item.price,
        fulfillment_details ? fulfillment_details : 'Unknown',
        delivery_address
      ]

      if sms_reminders_available
        line_item_row << Fulfillment::MarketplaceUtils.sms_opted_in?(fulfillable.order)
      end

      output << line_item_row
    end
  end
end
puts output_str
