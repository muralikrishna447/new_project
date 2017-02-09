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

    JOB_LOCK_KEY = 'fulfillment-order-export'

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

      # Determines whether a line item for an order should be fulfilled
      # for the given sku.
      def fulfillable_line_item?(order, line_item, sku)
        raise 'fulfillable_line_item? not implemented'
      end

      # Provides the set of orders to be considered for fulfillment.
      def orders(_search_params)
        raise 'orders not implemented'
      end

      # Optional lifecycle hook to perform some action before the CSV is saved
      # to storage.
      def before_save(_fulfillables, _params)
      end

      # Optional lifecycle hook to perform some action after the CSV is
      # successfully saved to storage.
      def after_save(_fulfillables, _params)
      end

      def perform(params)
        # Params hash keys are deserialized as strings coming out of Redis,
        # so we re-symbolize them here.
        job_params = job_params(params).deep_symbolize_keys
        Rails.logger.info("CSV order export starting perform with params: #{job_params}")
        raise 'skus param is required' unless job_params[:skus]
        raise 'skus param must not be empty' if job_params[:skus].empty?
        raise 'quantity param is required' unless job_params[:quantity]
        raise 'quantity param must be greater than zero' unless job_params[:quantity] > 0
        raise 'storage param must be specified' unless job_params[:storage]

        orders = orders(job_params[:search_params])
        Rails.logger.debug("Retrieved #{orders.length} orders")
        all_fulfillables = fulfillables(orders, job_params[:skus])
        all_fulfillables.select! { |fulfillable| include_order?(fulfillable.order) }
        sort!(all_fulfillables)
        to_fulfill = truncate(all_fulfillables, job_params[:quantity])

        before_save(to_fulfill, job_params)
        storage = Fulfillment::CSVStorageProvider.provider(job_params[:storage])
        storage.save(generate_output(to_fulfill), job_params.merge(type: type))
        after_save(to_fulfill, job_params)
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
        return false unless Fulfillment::PaymentStatusFilter.payment_captured?(order)
        # Filter out any order that has filtered tags
        unless (Shopify::Utils.order_tags(order) & FILTERED_TAGS).empty?
          Rails.logger.info("CSV order export filtering order with id #{order.id} " \
                            "because it has one or more filtered tags: #{order.tags}")
          return false
        end
        # Filter out orders with invalid addresses
        unless Fulfillment::FedexShippingAddressValidator.valid?(order)
          Rails.logger.warn("CSV order export filtering order with id #{order.id} because " \
                            "shipping address validation failed: #{order.attributes[:shipping_address].inspect}")
          return false
        end
        return false if Fulfillment::FraudFilter.fraud_suspected?(order)
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
            sum + fulfillable.quantity_for_line_item(line_item)
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

      private

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
