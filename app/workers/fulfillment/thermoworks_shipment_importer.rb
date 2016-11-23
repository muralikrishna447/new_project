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

      return []
    end

  end
end
