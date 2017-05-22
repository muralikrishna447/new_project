require_relative '../models/shopify/order'

module Fulfillment
  # This controls what SKUs are sent to Rosti for shipping,
  # so be very careful when updating this.
  ROSTI_FULFILLABLE_SKUS = [
    Shopify::Order::JOULE_SKU,
    Shopify::Order::JOULE_WHITE_SKU
  ].freeze
end
