module Fulfillment
  class Fulfillable
    attr_reader :order

    attr_reader :line_items

    def initialize(params = {})
      @order = params[:order]
      @line_items = params[:line_items]
    end

    # We open a fulfillment for each line item separately because
    # we are currently shipping line items separately. This will need
    # to change if we ever combine line items into a single shipment.
    def open_fulfillment
      line_items.each do |line_item|
        open_fulfillment_for_line_item(line_item)
      end
    end

    # To allow for opening fulfillments to be idempotent, we use the
    # submitted quantity for a line item if an open fulfillment
    # already exists. Otherwise, we use the line item's fulfillable_quantity
    # property, which takes refunds into account.
    def quantity_for_line_item(line_item)
      quantity = line_item.fulfillable_quantity
      existing = opened_fulfillment_for_line_item(line_item)
      if existing
        fulfillment_line_items = existing.line_items.select { |li| line_item.id == li.id }
        if fulfillment_line_items.length != 1
          raise "Expected a single fulfillment line item for order with id #{order.id} and " \
                "line item with id #{line_item.id}, but found #{fulfillment_line_items.length}"
        end
        quantity = fulfillment_line_items.first.quantity
      end
      quantity
    end

    def ==(other)
      order == other.order && line_items == other.line_items
    end

    private

    def opened_fulfillment_for_line_item(line_item)
      return nil unless order.respond_to?(:fulfillments)
      fulfillments = order.fulfillments.select do |fulfillment|
        !fulfillment.line_items.select { |li| line_item.id == li.id }.empty?
      end
      fulfillments.select! { |fulfillment| fulfillment.status == 'open' }
      if fulfillments.length > 1
        raise "Found multiple open fulfillments for order with id #{order.id} and " \
              "line item with id #{line_item.id}, expected only one"
      end
      fulfillments.first
    end

    def open_fulfillment_for_line_item(line_item)
      if opened_fulfillment_for_line_item(line_item)
        Rails.logger.info("Not opening fulfillment for order with id #{order.id} and " \
                          "line item with id #{line_item.id} because an open fulfillment already exists")
        return
      end

      Rails.logger.info("Opening fulfillment for order with id #{order.id} and " \
                        "line item with id #{line_item.id}")
      # TODO add retries
      fulfillment = ShopifyAPI::Fulfillment.new
      fulfillment.prefix_options[:order_id] = order.id
      fulfillment.attributes[:line_items] = [
        { id: line_item.id, quantity: line_item.fulfillable_quantity }
      ]
      fulfillment.attributes[:status] = 'open'
      fulfillment.attributes[:notify_customer] = false
      Shopify::Utils.send_assert_true(fulfillment, :save)
    end
  end
end
