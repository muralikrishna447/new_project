require 'fulfillment/order_search_provider'

module Fulfillment
  module FulfillableStrategy
    module Export
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def fulfillable_line_item?(order, line_item, sku)
          return false unless line_item
          return false if line_item.sku != sku
          # We may be able to get rid of all the nasty logic below if
          # we just check the value of fulfillable_quantity, but that's for
          # another day. This is just a short circuit so we prevent any
          # fully-refunded orders from shipping.
          return false if line_item.fulfillable_quantity < 1

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

        # When we are just exporting data, we search for orders from the
        # Shopify API.
        def orders(search_params)
          Fulfillment::ShopifyOrderSearchProvider.orders(search_params)
        end

        # Execute child jobs inline so that we can guarantee only one export
        # pipeline is running at once, but the jobs can be run separately
        # on a manual basis to recover from a failure.
        def after_save(_fulfillables, params)
          return unless params[:trigger_child_job]
          raise 'No child job class was specified' unless params[:child_job_class]
          params[:child_job_class].send(:perform, params[:child_job_params])
        end
      end
    end

    module OpenFulfillment
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # For idempotency we allow line items that were in the initial export
        # that already have an open fulfillment to be submitted in the case
        # that the submission fails and we have to re-run it. We just do a quick
        # check to make sure that the order wasn't cancelled or that the line
        # item shipped manually to minimize the window for race conditions on
        # order mutation.
        def fulfillable_line_item?(order, line_item, sku)
          return false unless line_item
          return false if line_item.sku != sku

          # Make sure the order wasn't canceled since exported.
          return false if order.cancelled_at

          # Make sure the order wasn't manually fulfilled since exported.
          fulfillments = order.fulfillments.select do |fulfillment|
            !fulfillment.line_items.select { |li| li.id == line_item.id }.empty?
          end
          return false unless fulfillments.select { |fulfillment| fulfillment.status == 'success' }.empty?

          true
        end

        # When opening fulfillment for orders prior to submitting, we
        # get the list of orders from a previously-created CSV from
        # Fulfillment::PendingOrderExporter.
        def orders(search_params)
          Fulfillment::PendingOrderSearchProvider.orders(search_params)
        end

        # Open fulfillments on fulfillable line items prior to saving the file.
        def before_save(fulfillables, params)
          if params[:open_fulfillment]
            Rails.logger.info("CSV order export opening fulfillments for #{fulfillables.length} orders")
            fulfillables.each(&:open_fulfillment)
          else
            Rails.logger.info("CSV order export not opening fulfilments for #{fulfillables.length} " \
                              'orders because open_fulfillment was false')
          end
        end
      end
    end
  end
end
