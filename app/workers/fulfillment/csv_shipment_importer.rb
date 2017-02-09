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

      def complete_shipment(shipment)
        shipment.fulfillments.each do |fulfillment|
          update_tracking(fulfillment, shipment)
          complete_fulfillment(fulfillment, shipment)
        end
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
          shipments.each { |shipment| complete_shipment(shipment) }
        else
          Rails.logger.info("CSV shipment import not completing fulfillment for #{shipments.length} " \
                            'shipments because complete_fulfillment is false')
        end
        after_import(shipments, params)
      end

      private

      def update_tracking(fulfillment, shipment)
        if tracking_updated?(fulfillment, shipment)
          Rails.logger.info('CSV shipment importer tracking was already updated for order with id ' \
                            "#{shipment.order.id}, name #{shipment.order.name} and fulfillment " \
                            "with id #{fulfillment.id}: #{shipment.tracking_company} #{shipment.tracking_numbers}")
          return
        end

        Rails.logger.info('CSV shipment import updating tracking for order with id ' \
                          "#{shipment.order.id}, name #{shipment.order.name} and fulfillment " \
                          "with id #{fulfillment.id}: #{shipment.tracking_company} #{shipment.tracking_numbers}")
        fulfillment.attributes[:tracking_company] = shipment.tracking_company
        fulfillment.attributes[:tracking_numbers] = shipment.tracking_numbers
        # We don't want to notify the customer here b/c it sends a shipment
        # update email instead of a shipment confirmation email and you
        # cannot update tracking and complete a fulfillment in a single call.
        fulfillment.attributes[:notify_customer] = false
        Shopify::Utils.send_assert_true(fulfillment, :save)
      end

      def complete_fulfillment(fulfillment, shipment)
        Rails.logger.info("CSV shipment import completing fulfillment for order with id " \
                          "#{shipment.order.id}, name #{shipment.order.name} and fulfillment with id #{fulfillment.id}")
        # We have to set this and save it back to Shopify so that Shopify
        # will send a shipment confirmation email on completion.
        fulfillment.attributes[:notify_customer] = true
        Shopify::Utils.send_assert_true(fulfillment, :save)
        Shopify::Utils.send_assert_true(fulfillment, :complete)
      end

      def tracking_updated?(fulfillment, shipment)
        fulfillment.attributes[:tracking_company] == shipment.tracking_company &&
          (fulfillment.attributes[:tracking_numbers] || []).sort == (shipment.tracking_numbers || []).sort
      end
    end
  end
end
