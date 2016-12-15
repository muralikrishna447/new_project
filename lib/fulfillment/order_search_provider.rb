module Fulfillment
  module OrderSearchProvider
    def self.orders(search_params)
      raise 'orders not implemented'
    end
  end

  # Searches orders via Shopify API according to params.
  module ShopifyOrderSearchProvider
    include Fulfillment::OrderSearchProvider

    def self.orders(search_params)
      # This query returns all open orders, including those that have been
      # partially fulfilled. Orders that have been completely fulfilled
      # or cancelled are excluded.
      search_params = (search_params || {}).merge(status: 'open')
      Shopify::Utils.search_orders(search_params)
    end
  end

  # Reads a list of order IDs from a file generated by
  # Fulfillment::PendingOrderExporter, then pulls each order
  # from the Shopify API by its ID to get its latest state.
  # Use this in a two-phase order export.
  module PendingOrderSearchProvider
    include Fulfillment::OrderSearchProvider

    def self.orders(search_params)
      raise 'search_params is required' unless search_params
      raise 'search_params.storage is required' unless search_params[:storage]
      storage = Fulfillment::CSVStorageProvider.provider(search_params[:storage])
      rows = CSV.parse(storage.read(search_params), headers: true)
      orders = []
      rows.each do |row|
        order_id = row['order_id'].to_i
        raise "Row has no order ID: #{row.inspect}" unless order_id
        # TODO add retries
        Rails.logger.debug("Retrieving order from Shopify with id #{order_id}")
        order = ShopifyAPI::Order.find(order_id)
        raise "Order not found: #{order_id}" unless order_id
        orders << order
      end
      orders
    end
  end
end
