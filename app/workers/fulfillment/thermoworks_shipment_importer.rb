require 'shopify_api'
require 'set'

module Fulfillment
  module ThermoworksShipmentImporter
    include Fulfillment::CSVShipmentImporter

    @queue = :ThermoworksShipmentImporter

    FORMAT = [
      'thermoworks_internal_id',
      'thermoworks_order_id',
      'cs_order_id',
      'cs_line_item_id',
      'order_creation_date',
      'recipient_name',
      'recipient_first name',
      'recipient_last name',
      'recipient_company',
      'address_line_1',
      'address_line_2',
      'city',
      'state',
      'zip',
      'phone',
      'email',
      'sku',
      'quantity',
      'ship_date',
      'tracking_number',
    ]

    def self.to_obj(row)
      if row.length != FORMAT.length
        raise "Unexpected row length #{row.length}"
      end
      obj = {}
      FORMAT.each_with_index{|n, i| obj[n] = row[i]}
      return obj
    end


    def self.to_shipments(csv_rows)
      # First row is always the header
      fulfilled_items = csv_rows[1..-1].collect{|csv_row| to_obj(csv_row)}

      Rails.logger.debug "Processing #{fulfilled_items.length} Thermoworks line items"

      # 1. Group fulfilled items by chefsteps order_id.
      by_order_id = fulfilled_items.group_by{|item| item['cs_order_id']}

      # 2. Assert that all line-items have the same tracking number
      Rails.logger.debug "Validating that tracking numbers for Thermoworks orders"
      tracking_numbers = {}
      by_order_id.each_pair{|order_id, line_items|
        tracking_numbers_for_order = line_items.group_by{|li|
          li['tracking_number']
        }.keys

        # NOTE: Technically we can handle this case, but it's
        # definitely not expected.  Bail early, inspect CSV, and make
        # sure everything looks sane
        if tracking_numbers_for_order.length != 1
          raise "Order #{order_id} has multiple tracking numbers: " \
                "#{tracking_numbers_for_order}"
        end
        tracking_numbers[order_id] = tracking_numbers_for_order[0]
      }

      # 3. Get order from Shopify and make sure it looks right
      Rails.logger.debug "Creating fulfillments for #{by_order_id.length} orders"
      to_fulfill = by_order_id.collect{|order_id, line_items|
        order = find_and_validate_order(order_id, line_items)
        {
          order: order,
          thermoworks_line_item_ids: line_items.collect{|li|
            li['cs_line_item_id']
          },
          tracking_number: tracking_numbers[order_id]
        }
      }

      # 4. Return a shipment... mixin is responsible for fulfilling
      shipments = to_fulfill.collect {|f|
        open_fulfillment_and_create_shipment(f)
      }
      return shipments
    end

    private

    def self.find_and_validate_order(order_id, line_items)
      Rails.logger.debug "Validating thermoworks order #{order_id}"
      order = ShopifyAPI::Order.find(order_id)
      raise "Can't find order #{order_id}" unless order

      in_csv = Set.new line_items.collect{|li| li['cs_line_item_id'].to_i}
      in_order = Set.new order.line_items.collect{|li| li.id}
      raise "Order #{order_id} doesn't contain all " \
            "line items for some reason" unless in_csv.subset? in_order

      order
    end

    def self.open_fulfillment_and_create_shipment(f)
      order = f[:order]
      line_item_ids = f[:thermoworks_line_item_ids]
      Rails.logger.debug "Creating open fulfillment for #{order.id}"
      fulfillment = ShopifyAPI::Fulfillment.new
      fulfillment.prefix_options[:order_id] = order.id
      fulfillment.attributes[:line_items] = line_item_ids.collect{|id| {id: id}}
      fulfillment.attributes[:status] = 'open'
      fulfillment.attributes[:notify_customer] = false
      #fulfillment.save

      return Fulfillment::Shipment.new(
        order: order,
        fulfillments: fulfillment,
        tracking_company: 'FedEx',
        tracking_numbers: [f[:tracking_number]],
      )
    end

  end
end
