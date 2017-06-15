require 'resque/plugins/lock'

module Fulfillment
  class FbaShipmentProcessor
    extend Resque::Plugins::Lock

    @queue = 'FbaShipmentProcessor'

    def self.lock(*args)
      'FbaShipmentProcessor'
    end

    # Scans Shopify for open orders looking for those with open fulfillments on
    # FBA-fulfilled SKUs. Syncs fulfillment status from FBA to Shopify and
    # updates tracking/completes fulfillment for each order.
    def self.perform(params)
      symbolized_params = params.deep_symbolize_keys
      Rails.logger.info "FbaShipmentProcessor starting perform with params #{symbolized_params}"
      Shopify::Utils.search_orders_with_each(status: 'open') do |order|
        process_order(order, symbolized_params)
      end

      Librato.increment 'fulfillment.fba.shipment-processor.success', sporadic: true
      Librato.tracker.flush
    end

    # Process a sync for the specified Shopify order. This is read only unless
    # you explicitly specify { complete_fulfillment: true } in the params.
    def self.process_order(order, params = {})
      Rails.logger.info "FbaShipmentProcessor processing order with id #{order.id}"

      order.line_items.each do |item|
        next unless Fulfillment::FBA_FULFILLABLE_SKUS.include?(item.sku)

        # Try to find a previously-opened fulfillment for the item.
        fulfillable = Fulfillment::Fulfillable.new(
          order: order, line_items: [item]
        )
        fulfillment = fulfillable.opened_fulfillment_for_line_item(item)
        unless fulfillment
          Rails.logger.info "FbaShipmentProcessor order with id #{order.id} " \
                            "and line item with id #{item.id} has no opened fulfillment, skipping"
          next
        end

        # Try to find a corresponding fulfillment order for the item in FBA.
        seller_fulfillment_order_id = Fulfillment::Fba.seller_fulfillment_order_id(order, fulfillment)
        response = Fulfillment::Fba.fulfillment_order_by_id(seller_fulfillment_order_id)
        unless response
          Rails.logger.info "FbaShipmentProcessor order with id #{order.id} " \
                            "and line item with id #{item.id} has no FBA fulfillment order " \
                            "with id #{seller_fulfillment_order_id}, skipping"
          next
          Librato.increment 'fulfillment.fba.shipment-processor.lines.skipped.count', sporadic: true
        end

        fulfillment_order = response.fetch('FulfillmentOrder')
        status = fulfillment_order.fetch('FulfillmentOrderStatus')
        Rails.logger.info "FbaShipmentProcessor order with id #{order.id} " \
                          "and line item with id #{item.id} has FBA fulfillment order " \
                          "with id #{seller_fulfillment_order_id} and status #{status}"
        Librato.increment "fulfillment.fba.shipment-processor.lines.#{status}.count", sporadic: true

        # Sync shipment status to Shopify as necessary.
        case status
        when 'RECEIVED'
          handle_pending(fulfillment_order, order, status)
        when 'INVALID'
          handle_error(fulfillment_order, order, status)
        when 'PLANNING'
          handle_pending(fulfillment_order, order, status)
        when 'PROCESSING'
          handle_pending(fulfillment_order, order, status)
        when 'CANCELLED'
          Rails.logger.info "FbaShipmentProcessor fulfillment order with id #{seller_fulfillment_order_id} " \
                            "was cancelled, not updating Shopify fulfillment for order with id #{order.id}"
        when 'COMPLETE'
          shipment = to_shipment(response, order, fulfillment)
          shipment.complete! if shipment && params[:complete_fulfillment]
        when 'COMPLETE_PARTIALLED'
          handle_error(fulfillment_order, order, status)
        when 'UNFULFILLABLE'
          handle_error(fulfillment_order, order, status)
        else
          handle_error(fulfillment_order, order, status)
        end
      end
    end

    # Translates an FBA fulfillment order to a Fulfillment::Shipment object.
    def self.to_shipment(response, order, fulfillment)
      carrier_codes = []
      tracking_numbers = []
      all_shipped = true
      response.fetch('FulfillmentShipment').each_value do |fba_shipment|
        all_shipped = false unless fba_shipment.fetch('FulfillmentShipmentStatus') == 'SHIPPED'
        fba_shipment.fetch('FulfillmentShipmentPackage').each_value do |fba_package|
          carrier_codes << fba_package.fetch('CarrierCode')
          tracking_numbers << fba_package.fetch('TrackingNumber')
        end
      end

      # Wait until all shipments associated with the fulfillment order have
      # shipped until we sync back to Shopfiy. It seems very unlikely we'll
      # encounter any problems with this any time soon given that mostly
      # there will just be a single shipment.
      unless all_shipped
        Rails.logger.info "FbaShipmentProcessor not all shipments have shipped for order with id #{order.id} " \
                          "and fulfillment order with id #{response.fetch('FulfillmentOrder').fetch('SellerFulfillmentOrderId')}, " \
                          'skipping'
        return nil
      end

      # This seems unlikely, but we'd still want to complete fulfillment
      # even if FBA doesn't give us tracking info.
      if carrier_codes.empty?
        Rails.logger.warn "FbaShipmentProcessor carrier codes is empty for order with id #{order.id} " \
                          "and fulfillment order with id #{fulfillment_order.fetch('SellerFulfillmentOrderId')}"
      end
      if tracking_numbers.empty?
        Rails.logger.warn "FbaShipmentProcessor tracking numbers is empty for order with id #{order.id} " \
                          "and fulfillment order with id #{fulfillment_order.fetch('SellerFulfillmentOrderId')}"
      end

      Fulfillment::Shipment.new(
        order: order,
        fulfillments: [fulfillment],
        tracking_company: reduce_carrier_codes(carrier_codes),
        tracking_numbers: tracking_numbers
      )
    end

    # This doesn't handle shipments with multiple carrier codes.
    # This seems extremely unlikely for just clamps, but
    # in the future we probably have to rejigger the fulfillments
    # on the order to be able to reflect how FBA shipped it.
    def self.reduce_carrier_codes(carrier_codes)
      carrier_code = carrier_codes.first
      # Need to match the carrier that Shopify expects to get links working, etc.
      carrier_code = 'Amazon Logistics US' if carrier_code == 'Amazon Logistics'
      carrier_code
    end

    private

    def self.handle_pending(fulfillment_order, order, status)
      Rails.logger.info "FbaShipmentProcessor fulfillment order with id #{fulfillment_order.fetch('SellerFulfillmentOrderId')} " \
                        "has pending status #{status}, not updating Shopify fulfillment for order with id #{order.id}"
    end

    SHIPPING_ERROR_TAG = 'shipping-error'.freeze
    SHIPPING_ERROR_MSG_ATTR = 'shipping-error-message'.freeze
    def self.handle_error(fulfillment_order, order, status)
      # If the order already has the error tag, assume it has already been
      # processed and move on.
      return if Shopify::Utils.order_tags(order).include?(SHIPPING_ERROR_TAG)

      Rails.logger.warn "FbaShipmentProcessor fulfillment order with id #{fulfillment_order.fetch('SellerFulfillmentOrderId')} " \
                        "has error status #{status}, tagging Shopify order with id #{order.id} for follow up"
      Shopify::Utils.add_to_order_tags(order, SHIPPING_ERROR_TAG)
      order.note_attributes.push(
        ShopifyAPI::NoteAttribute.new(
          name: SHIPPING_ERROR_MSG_ATTR,
          value: "FBA status is #{status}"
        )
      )
      Shopify::Utils.send_assert_true(order, :save)
    end
  end
end
