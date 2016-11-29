module Shopify
  class Utils
    # Returns the order tags as an array.
    def self.order_tags(order)
      order.tags.split(',').each(&:strip!)
    end

    # Adds an array of tags to the order, only if those tags don't
    # already exist on the order. Returns true if adding the tags
    # modified the order's tag list, false otherwise.
    def self.add_to_order_tags(order, tags)
      order_tags = order_tags(order)
      tags_to_add = []
      tags.each do |tag|
        tags_to_add << tag unless order_tags.include?(tag)
      end
      return false if tags_to_add.empty?

      order_tags.concat(tags_to_add)
      order.tags = order_tags.join(',')
      true
    end

    # Removes an array of tags from the order.
    def self.remove_from_order_tags(order, tags)
      order_tags = order_tags(order)
      tags.each { |tag| order_tags.delete(tag) }
      order.tags = order_tags.join(',')
    end

    def self.order_by_name(order_name)
      raise 'Order name must not be empty' if order_name.empty?
      orders = search_orders(name: order_name, status: 'any')
      raise "More than one order with number #{order_number}, expected only one" if orders.length > 1
      orders.first
    end

    PAGE_SIZE = 100

    # Careful! This pages through all orders matching the query.
    def self.search_orders(params, page_size = PAGE_SIZE)
      page = 1
      all_orders = []
      loop do
        Rails.logger.debug("Shopify search_orders fetching page #{page}")
        path = ShopifyAPI::Order.collection_path(params.merge(limit: page_size, page: page))
        # TODO add retries
        orders = ShopifyAPI::Order.find(:all, from: path)
        all_orders.concat(orders)
        break if orders.length < page_size
        page += 1
      end
      all_orders
    end

    def self.send_returns_true(obj, method_symbol)
      unless obj.send(method_symbol)
        raise "Calling #{method_symbol} returned false on #{obj.inspect}"
      end
    end
  end
end
