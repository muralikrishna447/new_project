require 'peddler'
require 'excon'

module Fulfillment
  module Fba
    def self.configure(params)
      @@outbound_shipment_client = MWS::FulfillmentOutboundShipment::Client.new(
        primary_marketplace_id: params[:mws_marketplace_id],
        merchant_id: params[:mws_merchant_id],
        aws_access_key_id: params[:mws_access_key_id],
        aws_secret_access_key: params[:mws_secret_access_key]
      )
      @@inventory_client = MWS::FulfillmentInventory::Client.new(
        primary_marketplace_id: params[:mws_marketplace_id],
        merchant_id: params[:mws_merchant_id],
        aws_access_key_id: params[:mws_access_key_id],
        aws_secret_access_key: params[:mws_secret_access_key]
      )
    end

    # Our unique ID for the fulfillment order in FBA. This is a hyphenated
    # combination of the Shopify order ID and the Shopify fulfillment ID.
    # We use the fulfillment ID b/c unlike Rosti we cannot submit the same
    # fulfillment ID multiple times in the case of a fulfillment error.
    def self.seller_fulfillment_order_id(order, fulfillment)
      "#{order.id}-#{fulfillment.id}"
    end

    # The displayable order ID that is printed on FBA packing slips.
    # Here we use the Shopify order name and the Shopify fulfillment ID.
    def self.displayable_order_id(order, fulfillment)
      "#{order.name}-#{fulfillment.id}"
    end

    # Retrieves an FBA fulfillment order by ID.
    def self.fulfillment_order_by_id(seller_fulfillment_order_id)
      begin
        response = @@outbound_shipment_client.get_fulfillment_order(seller_fulfillment_order_id).parse
      rescue Excon::Errors::BadRequest => e
        # When a fulfillment order does not exist, MWS returns
        # a 400 bad request. We have to check the error message
        # in the response to determine whether the order does not exist
        # or it really was a bad request. This sucks, but it's the best
        # option we have available.
        return nil if e.response.message == "Requested order '#{seller_fulfillment_order_id}' not found"
        raise e
      end
      response
    end

    def self.shopify_fulfillment_order(order, fulfillment)
      fulfillment_order_by_id(seller_fulfillment_order_id(order, fulfillment))
    end

    # Creates a new FBA fulfillment order for the specified Shopify::LineItem
    # the specified Fulfillment::Fulfillable.
    COMMENT = 'Thanks for shopping at ChefSteps!'.freeze # Printed on packing slips
    SHIPPING_SPEED = 'Standard'.freeze # The slowest/cheapest option
    def self.create_fulfillment_order(fulfillable, item)
      fulfillment = fulfillable.opened_fulfillment_for_line_item(item)
      unless fulfillment
        raise "Cannot create an FBA fulfillment order for order with id #{fulfillable.order.id} " \
              "and line item with id #{item.id} because no open fulfillment exists"
      end

      seller_fulfillment_order_id = seller_fulfillment_order_id(fulfillable.order, fulfillment)
      Rails.logger.info 'FbaOrderSubmitter creating FBA fulfillment order with ' \
                         "id #{seller_fulfillment_order_id} for order with id " \
                         "#{fulfillable.order.id} and line item with id #{item.id}"

      @@outbound_shipment_client.create_fulfillment_order(
        seller_fulfillment_order_id,
        displayable_order_id(fulfillable.order, fulfillment),
        fulfillable.order.processed_at,
        COMMENT,
        SHIPPING_SPEED,
        fba_shipping_address(fulfillable.order.shipping_address),
        [
          {
            'SellerSKU' => item.sku,
            'SellerFulfillmentOrderItemId' => item.id,
            'Quantity' => fulfillable.quantity_for_line_item(item)
          }
        ]
      )

      Rails.logger.info 'FbaOrderSubmitter successfully created FBA fulfillment order with ' \
                         "seller_fulfillment_order_id #{seller_fulfillment_order_id} " \
                         "for order with id #{fulfillable.order.id} and line item with id #{item.id}"
    rescue Excon::Errors::Error => e
      Rails.logger.error 'FbaOrderSubmitter encounted error creating order with ' \
                         "seller_fulfillment_order_id #{seller_fulfillment_order_id(fulfillable, item)} " \
                         "for order with id #{fulfillable.order.id} and line item with id #{item.id}: " \
                         "#{e.response.message}"
      raise e
    end

    # Returns in stock (ready to ship) inventory quantity for the specified SKU.
    def self.inventory_for_sku(sku)
      response = @@inventory_client.list_inventory_supply(seller_skus: [sku]).parse
      supply_list = response.fetch('InventorySupplyList')

      return 0 if supply_list.empty?
      if supply_list.length > 1
        raise "Expected only one InventorySupplyDetail for SKU #{sku}, saw multiple: #{response.inspect}"
      end

      supply_list.first[1].fetch('InStockSupplyQuantity').to_i
    end

    private

    def self.fba_shipping_address(shopify_shipping_address)
      shipping_address = {
        'Name' => shopify_shipping_address.name,
        'Line1' => shopify_shipping_address.address1,
        'City' => shopify_shipping_address.city,
        'StateOrProvinceCode' => shopify_shipping_address.province_code,
        'CountryCode' => shopify_shipping_address.country_code,
        'PostalCode' => shopify_shipping_address.zip,
        'PhoneNumber' => shopify_shipping_address.phone
      }
      unless shopify_shipping_address.address2.empty?
        shipping_address['Line2'] = shopify_shipping_address.address2
      end
      unless shopify_shipping_address.company.empty?
        shipping_address['Line3'] = shopify_shipping_address.company
      end
      shipping_address
    end
  end
end
