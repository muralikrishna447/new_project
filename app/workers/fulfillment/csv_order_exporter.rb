module Fulfillment
  # Mixin for implementing a CSV export of Shopify orders for fulfillment.
  # This is meant to be used in offline batch jobs as it has to crawl through
  # all open Shopify orders.
  module CSVOrderExporter
    # Orders with this tag are bumped to the top of the output.
    PRIORITY_TAG = 'shipping-priority'

    # Orders with these tags are not included in the output.
    FILTERED_TAGS = %w(
      shipping-started
      shipping-hold
      shipping-validation-error
    )

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Returns a string representing a type for your export.
      # This could be used for versioning export schemas or
      # in your file naming conventions.
      def type
        raise 'type not implemented'
      end

      # Returns parameters for running the export. By default this
      # just returns the same params that are passed in, but implementations
      # can override this method to provide custom params to the export.
      def job_params(params)
        params
      end

      # Returns an array of columns that will be used as the header for the
      # CSV export.
      def schema
        raise 'schema not implemented'
      end

      # Transforms the fulfillable an returns an array of arrays
      # (rows and columns) that will be included in the export CSV
      # for the fulfillable.
      def transform(_fulfillable)
        raise 'transform not implemented'
      end

      def perform(params)
        job_params = job_params(params)
        raise 'skus param is required' unless job_params[:skus]
        raise 'skus param must not be empty' if job_params[:skus].empty?
        raise 'quantity param is required' unless job_params[:quantity]
        raise 'quantity param must be greater than zero' unless job_params[:quantity] > 0
        raise 'storage param must be specified' unless job_params[:storage]

        # This query returns all open orders, including those that have been
        # partially fulfilled. Orders that have been completely fulfilled
        # or cancelled are excluded.
        orders = Shopify::Utils.search_orders(status: 'open')
        fulfillables = fulfillables(orders, job_params[:skus])
        fulfillables.select! { |fulfillable| include_order?(fulfillable.order) }
        sort!(fulfillables)
        to_fulfill = truncate(fulfillables, job_params[:quantity])

        open_fulfillments(to_fulfill) if job_params[:open_fulfillment]

        storage = Fulfillment::CSVStorageProvider.provider(job_params[:storage])
        storage.save(generate_output(to_fulfill), job_params.merge(type: type))
      end

      def fulfillables(orders, skus)
        fulfillables = []
        orders.each do |order|
          fulfillable_line_items = []
          order.line_items.each do |line_item|
            skus.each do |sku|
              fulfillable_line_items << line_item if fulfillable_line_item?(order, line_item, sku)
            end
          end
          next if fulfillable_line_items.empty?
          fulfillables << Fulfillment::Fulfillable.new(
            order: order,
            line_items: fulfillable_line_items
          )
        end
        fulfillables
      end

      def include_order?(order)
        # Filter out any order that has filtered tags
        return false unless (Shopify::Utils.order_tags(order) & FILTERED_TAGS).empty?
        # Filter out orders with invalid addresses
        return false unless Fulfillment::FedexShippingAddressValidator.valid?(order)
        true
      end

      def sort!(fulfillables)
        priority_order_ids = {}
        fulfillables.each_index do |i|
          tags = Shopify::Utils.order_tags(fulfillables[i].order)
          priority_order_ids[fulfillables[i].order.id] = i if tags.include?(PRIORITY_TAG)
        end

        fulfillables.sort! do |x, y|
          # Default sort order is by processing timestamp, ascending
          val = DateTime.parse(x.order.processed_at) <=> DateTime.parse(y.order.processed_at)

          # Special handling for priority orders
          x_has_priority = !priority_order_ids[x.order.id].nil?
          y_has_priority = !priority_order_ids[y.order.id].nil?
          if x_has_priority && y_has_priority
            # When comparing two priority orders, the one with the lower index wins
            val = priority_order_ids[x.order.id] <=> priority_order_ids[y.order.id]
          elsif x_has_priority && !y_has_priority
            val = -1
          elsif !x_has_priority && y_has_priority
            val = 1
          end
          val
        end
      end

      def truncate(fulfillables, quantity)
        to_fulfill = []
        quantity_processed = 0
        fulfillables.each do |fulfillable|
          break if quantity_processed == quantity

          fulfillable_quantity = fulfillable.line_items.inject(0) do |sum, line_item|
            sum + line_item.quantity
          end

          # We want to ship all the inventory we have available at any given time,
          # so we'll skip an order if it has quantity > 1 and we don't have enough
          # inventory to ship it right now.
          next if (quantity_processed + fulfillable_quantity) > quantity

          quantity_processed += fulfillable_quantity
          to_fulfill << fulfillable
        end
        to_fulfill
      end

      # We open a fulfillment for each line item separately because
      # we are currently shipping line items separately.
      def open_fulfillments(fulfillables)
        fulfillables.each do |fulfillable|
          fulfillable.line_items.each do |line_item|
            open_fulfillment_for_line_item(fulfillable.order, line_item)
          end
        end
      end

      private

      def open_fulfillment_for_line_item(order, line_item)
        # TODO add retries
        fulfillment = ShopifyAPI::Fulfillment.new
        fulfillment.prefix_options[:order_id] = order.id
        fulfillment.attributes[:line_items] = [{ id: line_item.id }]
        fulfillment.attributes[:status] = 'open'
        fulfillment.attributes[:notify_customer] = false
        fulfillment.save
      end

      def fulfillable_line_item?(order, line_item, sku)
        return false unless line_item
        return false if line_item.sku != sku
        # line_item.fulfillment_status doesn't seem to always have the
        # most recent status, probably due to Shopify's caching. Always examine
        # the status of order.fulfillment.
        order.fulfillments.each do |fulfillment|
          fulfillment.line_items.each do |fulfillment_line_item|
            next unless fulfillment_line_item.id == line_item.id
            return false if fulfillment.status == 'success'
            return false if fulfillment.status == 'open'
            # If fulfillment for this line item was previously cancelled,
            # we want to open a new fulfillment.
            return true
          end
        end
        # No fulfillment for the line item currently exists,
        # so we want to open a new fulfillment.
        true
      end

      def generate_output(fulfillables)
        CSV.generate(force_quotes: true) do |output|
          output << schema
          fulfillables.each do |fulfillable|
            transform(fulfillable).each { |line_item| output << line_item }
          end
        end
      end
    end
  end
end
