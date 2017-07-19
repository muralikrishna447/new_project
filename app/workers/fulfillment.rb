require_relative '../models/shopify/order'

module Fulfillment
  # This controls what SKUs are sent to Rosti for shipping,
  # so be very careful when updating this.
  ROSTI_FULFILLABLE_SKUS = [
    Shopify::Order::JOULE_SKU,
    Shopify::Order::JOULE_WHITE_SKU
  ].freeze

  # This controls what SKUs are sent to FBA for shipping,
  # so be very careful when updating this.
  FBA_FULFILLABLE_SKUS = [
    Shopify::Order::BIG_CLAMP_SKU
  ].freeze

  # Orders with these tags are not sent for fulfillment.
  FILTERED_TAGS = [
    'shipping-hold',
    Fulfillment::ShippingAddressValidator::VALIDATION_ERROR_TAG
  ].freeze
end
