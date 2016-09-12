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
  end
end
