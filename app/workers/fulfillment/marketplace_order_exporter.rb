require 'csv'

module Fulfillment
  class MarketplaceOrderExporter
    @queue = 'MarketplaceOrderExporter'

    def self.perform(params)
      symbolized_params = params.deep_symbolize_keys
      raise 'vendor is a required param' unless symbolized_params[:vendor]

      export_id = SecureRandom.hex
      Rails.logger.info "MarketplaceOrderExporter beginning export with id #{export_id} for vendor #{symbolized_params[:vendor]}"

      mail_params = symbolized_params.merge(export_id: export_id)
      begin
        output = generate_csv_output(symbolized_params)
        mail_params.merge!(
          success: true,
          output: output
        )
      rescue => e
        mail_params[:success] = false
        raise e
      ensure
        if symbolized_params[:email]
          MarketplaceOrderExporterMailer.prepare(mail_params).deliver
        end
      end

      output
    end

    def self.generate_csv_output(params)
      fulfillables = []
      Shopify::Utils.search_orders_with_each(status: 'open') do |order|
        fulfillable_line_items = []
        order.line_items.each do |line_item|
          if Fulfillment::MarketplaceUtils.fulfillable_line_item?(order, line_item, params[:vendor])
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
        if Fulfillment::MarketplaceUtils.sms_reminders_available?(params[:vendor])
          Rails.logger.debug("Vendor #{params[:vendor]} has SMS reminders available, will add to export")
          sms_reminders_available = true
          header_row << 'SMS Opted In'
        else
          Rails.logger.debug("Vendor #{params[:vendor]} does not have SMS reminders available, not adding to export")
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
        output_str
      end
    end
  end
end
