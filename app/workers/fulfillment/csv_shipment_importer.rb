require 'csv'

module Fulfillment
  # Mixin for importing shipment data from a fulfillment
  # provider in CSV format and updating Shopify.
  module CSVShipmentImporter
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

      # Returns an array of ShopifyAPI::Fulfillment objects in the order
      # for the given array of line item IDs. This logic seems pretty
      # universal across fulfillment providers but you can override this
      # method in your implementation if needed.
      def fulfillments(order, line_item_ids)
        fulfillments = {}
        found_line_item_ids = {}
        order.fulfillments.each do |fulfillment|
          fulfillment.line_items.each do |line_item|
            if line_item_ids.include?(line_item.id)
              fulfillments[fulfillment.id] = fulfillment if fulfillment.status == 'open'
              found_line_item_ids[line_item.id] = true
            end
          end
        end

        # We expect that there should be existing fulfillments for all
        # specified line item IDs. If not, we've got a problem.
        missing_line_item_ids = []
        line_item_ids.each do |line_item_id|
          unless found_line_item_ids[line_item_id] == true
            missing_line_item_ids << line_item_id
          end
        end
        unless missing_line_item_ids.empty?
          raise "Expected to find fulfillments for order with id #{order.id} and line item ids #{missing_line_item_ids}"
        end

        fulfillments.values
      end

      def complete_shipment(shipment)
        shipment.fulfillments.each do |fulfillment|
          update_tracking(fulfillment, shipment)
          complete_fulfillment(fulfillment)
        end
      end

      # TODO eventually store the shipment serial numbers somewhere.
      # For now they'll be in storage and we can backfill them some place when
      # we actually know how we're going to use them.
      def perform(params)
        job_params = job_params(params)
        storage = Fulfillment::CSVStorageProvider.provider(job_params[:storage])
        csv_str = storage.read(job_params)

        rows = CSV.parse(csv_str, headers: job_params[:headers])
        shipments = to_shipments(rows)

        if job_params[:complete_fulfillment]
          shipments.each { |shipment| complete_shipment(shipment) }
        end
      end

      private

      def update_tracking(fulfillment, shipment)
        fulfillment.attributes[:tracking_company] = shipment.tracking_company
        fulfillment.attributes[:tracking_numbers] = shipment.tracking_numbers
        # We don't want to notify the customer here b/c it sends a shipment
        # update email instead of a shipment confirmation email and you
        # cannot update tracking and complete a fulfillment in a single call.
        fulfillment.attributes[:notify_customer] = false
        fulfillment.save
      end

      def complete_fulfillment(fulfillment)
        # We have to set this and save it back to Shopify so that Shopify
        # will send a shipment confirmation email on completion.
        fulfillment.attributes[:notify_customer] = true
        fulfillment.save
        fulfillment.complete
      end
    end
  end
end
