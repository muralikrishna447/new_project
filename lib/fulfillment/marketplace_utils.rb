module Fulfillment
  class MarketplaceUtils
    # Returns line items in the order that are fulfillable for the
    # specified vendor and fulfillment details.
    def self.items_for_fulfillment(order, vendor, fulfillment_details)
      order.line_items.select do |item|
        next unless fulfillable_line_item?(order, item, vendor)
        next unless fulfillment_details(item) == fulfillment_details
        true
      end
    end

    # Determines whether an order and its line item are fulfillable for
    # the specified vendor.
    # TODO eventually this per-vendor logic should move into the
    # main fulfillment export.
    def self.fulfillable_line_item?(order, line_item, vendor)
      return false unless line_item
      return false if line_item.vendor != vendor
      return false if line_item.fulfillable_quantity < 1
      return false unless Fulfillment::PaymentStatusFilter.payment_captured?(order)
      order.fulfillments.each do |fulfillment|
        fulfillment.line_items.each do |fulfillment_line_item|
          next unless fulfillment_line_item.id == line_item.id
          if fulfillment.status == 'success' || fulfillment.status == 'open'
            Rails.logger.debug("Skipping order with id #{order.id} and " \
                               "fulfillment with id #{fulfillment.id} because fulfillment " \
                               "status is #{fulfillment.status}")
            return false
          end
          Rails.logger.debug("Order with id #{order.id} and fulfillment with " \
                            "id #{fulfillment.id} is fulfillable fulfillment status is #{fulfillment.status}")
          return true
        end
      end
      Rails.logger.debug("Order with id #{order.id} and line " \
                        "item with id #{line_item.id} is fulfillable because no fulfillment exists")
      true
    end

    # Returns the line item property containing the selected pickup option,
    # or nil if none was selected.
    def self.pickup_details(line_item)
      # At various times we've stored the pickup time property under different names (sigh).
      properties = ['Pickup Time', 'customizery_1', 'Pickup Times', 'Pickup Details']
      pickup_details = line_item.properties.select { |p| properties.include?(p.name) }
      if pickup_details.empty?
        Rails.logger.warn "No pickup details property found for line item #{line_item.inspect}"
        return nil
      end
      raise "Multiple pickup details properties found for line item #{line_item.inspect}" if pickup_details.length > 1
      pickup_details.first.value
    end

    # Returns the line item property containing the selected delivery option,
    # or nil if none was selected.
    def self.delivery_details(line_item)
      delivery_details = line_item.properties.select { |p| p.name == 'Delivery Details' }
      if delivery_details.empty?
        Rails.logger.warn "No delivery details property found for line item #{line_item.inspect}"
        return nil
      end
      raise "Multiple delivery details properties found for line item #{line_item.inspect}" if delivery_details.length > 1
      delivery_details.first.value
    end

    # Returns a string representing the fulfillment option selected
    # for the line item, or nil if none was selected.
    def self.fulfillment_details(line_item)
      # We have some variants with no option so we assume they are pickup
      # if they are not explicitly a delivery variant.
      delivery_details = delivery_details(line_item) if delivery?(line_item)
      delivery_details || pickup_details(line_item)
    end

    # Returns true if the delivery variant was selected for the line item,
    # false otherwise.
    def self.delivery?(line_item)
      line_item.variant_title == 'Delivery'
    end

    # Returns true if the pickup variant was selected for the line item,
    # false otherwise.
    def self.pickup?(line_item)
      line_item.variant_title == 'Pickup'
    end

    # Returns true if the customer opted in to receive SMS reminders
    # about the specified order during checkout, false otherwise.
    def self.sms_opted_in?(order)
      return true if order.note_attributes.find do |attr|
        attr.name == 'sms-opted-in' && attr.value == 'true'
      end
      false
    end

    # Returns true if the vendor has SMS reminders available,
    # false otherwise.
    def self.sms_reminders_available?(vendor)
      vendor_metafields(vendor).find do |metafield|
        return true if metafield.namespace == 'chefsteps' &&
                       metafield.key == 'sms_reminders_available' &&
                       metafield.value == 'true'
      end
      false
    end

    # We store vendor-level configuration as metafields on the
    # vendor collection with a title equal to the vendor name.
    def self.vendor_metafields(vendor)
      path = ShopifyAPI::SmartCollection.collection_path(title: vendor)
      collections = ShopifyAPI::SmartCollection.find(:all, from: path)

      return [] if collections.empty?

      if collections.length > 1
        Rails.logger.warn "Multiple collections exist for the vendor #{vendor}, " \
                          'not going to guess which one is correct'
        return []
      end

      collections.first.metafields
    end
  end
end
