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

      # 3. Create an open fulfillment for those line-items
      Rails.logger.debug "Creating fulfillments for #{by_order_id.length} orders"
      by_order_id.each_pair{|order_id, line_items|
        tracking_number = tracking_numbers[order_id]
        create_open_fulfillment(order_id, line_items)
      }

      # 4. Return a shipment... mixin is responsible for fulfilling
      return []
    end

    # TODO: should we do this on export???
    def self.create_open_fulfillment(order_id, line_items)
      Rails.logger.debug "Creating open fulfillment for #{order_id}"
      order = ShopifyAPI::Order.find(order_id)
      raise "Can't find order #{order_id}" unless order

      fulfillment = ShopifyAPI::Fulfillment.new
      fulfillment.prefix_options[:order_id] = order.id
      fulfillment.attributes[:line_items] = line_items.collect{|li|
        {id: li['cs_line_item_id']}
      }
      fulfillment.attributes[:status] = 'open'
      fulfillment.attributes[:notify_customer] = false
      puts "order is #{order}"
      puts fulfillment
    end

  end
end
