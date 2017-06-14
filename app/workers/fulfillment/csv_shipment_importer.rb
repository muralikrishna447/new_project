require 'csv'

module Fulfillment
  # Mixin for importing shipment data from a fulfillment
  # provider in CSV format and updating Shopify.
  module CSVShipmentImporter
    JOB_LOCK_KEY = 'fulfillment-shipment-import'

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Returns parameters for running the import. By default this
      # just returns the same params that are passed in, but implementations
      # can override this method to provide custom params to the import.
      def job_params(params)
        params
      end

      # Converts rows in the CSV import file into array of
      # Fulfillment::Shipment. Implement this according to your CSV schema.
      def to_shipments(_csv_rows)
        raise 'to_shipments not implemented'
      end

      # Optional lifecycle hook to implement.
      def after_import(_shipments, _params)
      end

      # Returns an array of ShopifyAPI::Fulfillment objects in the order
      # for the given array of line item IDs. This logic seems pretty
      # universal across fulfillment providers but you can override this
      # method in your implementation if needed.
      def fulfillments(order, line_item_ids)
        fulfillments = {}
        found_line_item_ids = {}
        order.fulfillments.each do |fulfillment|
          fulfillment.line_items.each do |line_item|
            next unless line_item_ids.include?(line_item.id)
            found_line_item_ids[line_item.id] = true
            if fulfillment.status == 'open'
              Rails.logger.info("CSV shipment import found open fulfillment with id #{fulfillment.id} " \
                                "for order with id #{order.id}, name #{order.name} and line item with id #{line_item.id}")
              fulfillments[fulfillment.id] = fulfillment
            else
              Rails.logger.info("CSV shipment import not including fulfillment with id #{fulfillment.id} " \
                                "because status is #{fulfillment.status} for order with id #{order.id}, " \
                                "name #{order.name} and line item with id #{line_item.id}")
            end
          end
        end

        # We expect that there should be existing fulfillments for all
        # specified line item IDs. If not, we've got a problem.
        missing_line_item_ids = []
        line_item_ids.each do |line_item_id|
          unless found_line_item_ids[line_item_id] == true
            Rails.logger.error("CSV shipment import expected to find fulfillment for order with id #{order.id} " \
                              " and line item id #{line_item_id}")
            missing_line_item_ids << line_item_id
          end
        end
        unless missing_line_item_ids.empty?
          raise "Expected to find fulfillment for order with id #{order.id} and line item ids #{missing_line_item_ids}"
        end

        fulfillments.values
      end

      # TODO eventually store the shipment serial numbers somewhere.
      # For now they'll be in storage and we can backfill them some place when
      # we actually know how we're going to use them.
      def perform(params)
        # Params hash keys are deserialized as strings coming out of Redis,
        # so we re-symbolize them here.
        job_params = job_params(params).deep_symbolize_keys
        Rails.logger.info("CSV shipment import starting perform with params: #{job_params}")

        storage = Fulfillment::CSVStorageProvider.provider(job_params[:storage])
        csv_str = storage.read(job_params)

        rows = CSV.parse(csv_str, headers: job_params[:headers])
        shipments = to_shipments(rows)

        if job_params[:complete_fulfillment]
          Rails.logger.info("CSV shipment import completing fulfillment for #{shipments.length} shipments")
          shipments.each(&:complete!)
        else
          Rails.logger.info("CSV shipment import not completing fulfillment for #{shipments.length} " \
                            'shipments because complete_fulfillment is false')
        end
        after_import(shipments, params)
      end
    end
  end
end
