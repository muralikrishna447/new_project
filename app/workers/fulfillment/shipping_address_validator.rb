require 'shopify_api'

module Fulfillment
  class ShippingAddressValidator
    VALIDATION_MESSAGE_NOTE_KEY = 'address-validation-message'

    VALIDATION_ERROR_TAG = 'shipping-validation-error'

    @queue = :ShippingAddressValidator

    def self.perform(skus)
      Rails.logger.info("ShippingAddressValidator starting perform with SKUs #{skus}")
      valid_count = 0
      invalid_count = 0
      Shopify::Utils.search_orders_with_each(status: 'open') do |order|
        next unless should_validate?(order, skus)
        if validate(order)
          valid_count += 1
        else
          invalid_count += 1
          order_age_days = (Time.now - Time.parse(order.processed_at)) / 60 / 60 / 24
          Librato.measure 'fulfillment.address-validator.invalid.age', order_age_days
        end
      end

      Rails.logger.info("ShippingAddressValidator complete, found #{valid_count} " \
                        "open orders with valid addresses and #{invalid_count} invalid")
      Librato.increment 'fulfillment.address-validator.success', sporadic: true
      Librato.increment 'fulfillment.address-validator.valid.count', by: valid_count, sporadic: true
      Librato.increment 'fulfillment.address-validator.invalid.count', by: invalid_count, sporadic: true
      Librato.tracker.flush
    end

    def self.validate(order)
      validation = Fulfillment::FedexShippingAddressValidator.validate(order)

      # Clear any previous validation errors if address is now valid.
      if validation[:is_valid]
        Rails.logger.info("ShippingAddressValidator order with id #{order.id} is valid, " \
                          'clearing any existing validation errors')
        clear_validation_errors(order)
        return true
      end

      # Concatenate all validation messages into one string to put in Shopify.
      message = validation[:messages].join(', ')

      # Don't bother saving the order back to Shopify if already handled.
      return false if handled?(order, message)
      Rails.logger.warn("ShippingAddressValidator order with id #{order.id} is invalid, " \
                        "adding message #{message}")
      add_validation_error(order, message)
      false
    end

    def self.handled?(order, message)
      has_error_tag = Shopify::Utils.order_tags(order).include?(VALIDATION_ERROR_TAG)
      note = validation_note(order)
      return true if has_error_tag && note && note.attributes[:value] == message
      false
    end

    def self.validation_note(order)
      order.note_attributes.select { |attr| attr.attributes[:name] == VALIDATION_MESSAGE_NOTE_KEY }.first
    end

    def self.clear_validation_errors(order)
      has_error_tag = Shopify::Utils.order_tags(order).include?(VALIDATION_ERROR_TAG)
      Shopify::Utils.remove_from_order_tags(order, [VALIDATION_ERROR_TAG]) if has_error_tag
      note = validation_note(order)
      # ShopifyAPI::NoteAttribute doesn't seem to implement equality so
      # have to do a delete the ugly way.
      if note
        order.note_attributes.delete_if do |attr|
          attr.attributes[:name] == note.attributes[:name] &&
            attr.attributes[:value] == note.attributes[:value]
        end
      end
      save_order_fields(order) if has_error_tag || note
    end

    def self.add_validation_error(order, message)
      Shopify::Utils.add_to_order_tags(order, [VALIDATION_ERROR_TAG])

      # Update existing message or add it to array if it doesn't exist.
      note = validation_note(order)
      if note
        note.attributes[:value] = message
      else
        order.note_attributes.push(
          name: VALIDATION_MESSAGE_NOTE_KEY,
          value: message
        )
      end

      save_order_fields(order)
    end

    def self.should_validate?(order, skus)
      if Shopify::Utils.line_items_for_skus(order, skus).empty?
        Rails.logger.info "ShippingAddressValidator order with id #{order.id} " \
                          "has no line items matching skus #{skus}, skipping"
        return false
      end
      # The Shopify order query API doesn't allow you to search for things
      # that are not fulfilled or partially fulfilled, so we filter out any
      # open orders that are fulfilled here. The address doesn't matter if
      # it has already shipped!
      if order.fulfillment_status == 'fulfilled'
        Rails.logger.info "ShippingAddressValidator order with id #{order.id} " \
                          'is fulfilled, skipping'
        return false
      end
      true
    end

    private

    def self.save_order_fields(order)
      # We create a new order object with the minimal set of fields so as
      # to not trigger Shopify's built-in address validation which may
      # cause the save to fail.
      updated = ShopifyAPI::Order.new(
        id: order.id,
        note_attributes: order.note_attributes,
        tags: order.tags
      )

      Shopify::Utils.send_assert_true(updated, :save)
    end
  end
end
