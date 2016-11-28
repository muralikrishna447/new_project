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
        Rails.logger.info("CSV order export starting perform with params: #{params}")

        # This query returns all open orders, including those that have been
        # partially fulfilled. Orders that have been completely fulfilled
        # or cancelled are excluded.
        search_params = (job_params[:search_params] || {}).merge(status: 'open')
        orders = Shopify::Utils.search_orders(search_params)
        Rails.logger.debug("Got #{orders.length} orders from Shopify API")
        all_fulfillables = fulfillables(orders, job_params[:skus])
        all_fulfillables.select! { |fulfillable| include_order?(fulfillable.order) }
        sort!(all_fulfillables)
        to_fulfill = truncate(all_fulfillables, job_params[:quantity])

        if job_params[:open_fulfillment]
          Rails.logger.info("CSV order export opening fulfillments for #{to_fulfill.length} orders")
          open_fulfillments(to_fulfill)
        else
          Rails.logger.info("CSV order export not opening fulfilments for #{to_fulfill.length} orders")
        end

        storage = Fulfillment::CSVStorageProvider.provider(job_params[:storage])
        storage.save(generate_output(to_fulfill), job_params.merge(type: type))
      end

      def fulfillables(orders, skus)
        fulfillables = []
        orders.each do |order|
          fulfillable_line_items = []
          order.line_items.each do |line_item|
            skus.each do |sku|
              if fulfillable_line_item?(order, line_item, sku)
                Rails.logger.info("CSV order export found fulfillable line item for order " \
                                  "with id #{order.id}, line item id #{line_item.id}, and sku #{sku}")
                fulfillable_line_items << line_item
              end
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
        unless (Shopify::Utils.order_tags(order) & FILTERED_TAGS).empty?
          Rails.logger.info("CSV order export filtering order with id #{order.id} " \
                            "because it has one or more filtered tags: #{order.tags}")
          return false
        end
        # Filter out orders with invalid addresses
        unless Fulfillment::FedexShippingAddressValidator.valid?(order)
          Rails.logger.info("CSV order export filtering order with id #{order.id} because " \
                            "shipping address validation failed: #{order.attributes[:shipping_address].inspect}")
          return false
        end
        true
      end

      def sort!(fulfillables)
        priority_order_ids = {}
        fulfillables.each_index do |i|
          tags = Shopify::Utils.order_tags(fulfillables[i].order)
          if tags.include?(PRIORITY_TAG)
            Rails.logger.info("CSV order export prioritizing order with id " \
                              "#{fulfillables[i].order.id} because it has priority tag")
            priority_order_ids[fulfillables[i].order.id] = true
          end
        end

        fulfillables.sort! do |x, y|
          # Default sort order is by processing timestamp, ascending
          val = DateTime.parse(x.order.processed_at) <=> DateTime.parse(y.order.processed_at)

          # Special handling for priority orders
          x_has_priority = !priority_order_ids[x.order.id].nil?
          y_has_priority = !priority_order_ids[y.order.id].nil?
          if x_has_priority && !y_has_priority
            val = -1
          elsif !x_has_priority && y_has_priority
            val = 1
          end
          # If both orders have priority, take the default sort order.
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
          if (quantity_processed + fulfillable_quantity) > quantity
            Rails.logger.info("CSV order export skipping order with id #{fulfillable.order.id} " \
                              "because there is not enough quantity to fulfill it in this export")
            next
          end

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
        Rails.logger.info("CSV order export opening fulfillment for order with id #{order.id} and " \
                          "line item with id #{line_item.id}")
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
        Rails.logger.info("CSV order export checking if order with id #{order.id} and line " \
                          "item id #{line_item.id} is fulfillable for sku #{line_item.sku}")
        order.fulfillments.each do |fulfillment|
          fulfillment.line_items.each do |fulfillment_line_item|
            next unless fulfillment_line_item.id == line_item.id
            if fulfillment.status == 'success' || fulfillment.status == 'open'
              Rails.logger.info("CSV order export skipping order with id #{order.id} and " \
                                "fulfillment with id #{fulfillment.id} because fulfillment " \
                                "status is #{fulfillment.status}")
              return false
            end
            # If fulfillment for this line item was previously cancelled,
            # we want to open a new fulfillment.
            Rails.logger.info("CSV order export order with id #{order.id} and fulfillment with " \
                              "id #{fulfillment.id} is fulfillable fulfillment status is #{fulfillment.status}")
            return true
          end
        end
        # No fulfillment for the line item currently exists,
        # so we want to open a new fulfillment.
        Rails.logger.info("CSV order export order with id #{order.id} and line " \
                          "item with id #{line_item.id} is fulfillable because no fulfillment exists")
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
