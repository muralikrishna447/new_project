module Shopify
  class Utils
    # TODO write tests for this
    def self.add_to_tags(order, tags)
      # Only add tags that don't already exist
      order_tags = tags(order)
      tags_to_add = []
      tags.each do |tag|
        tags_to_add << tag unless order_tags.include?(tag)
      end
      return false if tags_to_add.empty?

      order_tags.concat(tags_to_add)
      order.tags = order_tags.join(',')
      true
    end

    # TODO write tests for this
    def self.tags(order)
      order.tags.split(',').each(&:strip!)
    end
  end
end
