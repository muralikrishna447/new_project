module Shipwire
  class Order
    JOULE_SKU = 'cs10001'

    # Shipwire's unique order ID
    attr_reader :id

    # Shipwire's order number
    attr_reader :number

    # Shipwire's order status (e.g., submitted, processing, completed, delivered)
    attr_reader :status

    # Array of Shipwire::Tracking
    attr_reader :trackings

    # Array of Shipwire::Hold
    attr_reader :holds

    def initialize(params = {})
      @id = params[:id]
      @number = params[:number]
      @status = params[:status]
      @trackings = params[:trackings]
      @holds = params[:holds]
    end

    def fulfillment_complete?
      status == 'completed' || status == 'delivered'
    end

    def fulfillment_pending?
      status == 'submitted' || status == 'unprocessed' || status == 'processed'
    end

    def fulfillment_held?
      status == 'held'
    end

    def ==(other)
      id == other.id &&
        number == other.number &&
        status == other.status &&
        trackings == other.trackings &&
        holds == other.holds
    end

    def sync_to_shopify(shopify_order)
      validate_sync(shopify_order)

      # For an existing fulfillment, first we sync the trackings and then save.
      # Then we complete the fulfillment in Shopify if Shipwire says it's done.
      shopify_fulfillment = joule_fulfillment(shopify_order)
      if shopify_fulfillment
        sync_trackings_to_shopify(shopify_fulfillment)
        shopify_fulfillment.save
        shopify_fulfillment.complete if fulfillment_complete?
      else
        # For a new fulfillment, we create a new object and save it to Shopify.
        shopify_fulfillment = ShopifyAPI::Fulfillment.new
        shopify_fulfillment.prefix_options[:order_id] = shopify_order.id
        shopify_fulfillment.attributes[:line_items] = [{ id: joule_line_item(shopify_order).id }]
        sync_trackings_to_shopify(shopify_fulfillment)
        if fulfillment_complete?
          shopify_fulfillment.attributes[:status] = 'success'
        elsif fulfillment_pending? || fulfillment_held?
          shopify_fulfillment.attributes[:status] = 'open'
        end
        shopify_fulfillment.save
      end

      # Lastly we add tags to the Shopify order if Shipwire held it.
      sync_held_state_to_shopify(shopify_order) if fulfillment_held?
    end

    private_class_method
    def self.from_hash(order_hash)
      Shipwire::Order.new(
        id: order_hash.fetch('id'),
        number: order_hash.fetch('orderNo'),
        status: order_hash.fetch('status'),
        trackings: Shipwire::Tracking.array_from_hash(order_hash.fetch('trackings')),
        holds: Shipwire::Hold.array_from_hash(order_hash.fetch('holds'))
      )
    end

    private

    def validate_sync(shopify_order)
      # Basic sanity check to be doubly sure we are syncing the correct order.
      if number != "#{shopify_order.name}.1"
        raise "Sync from Shipwire order with id #{id} and number #{number} does not match Shopify order name #{shopify_order.name}"
      end
    end

    def joule_fulfillment(shopify_order)
      shopify_order.fulfillments.each do |fulfillment|
        fulfillment.line_items.each do |line_item|
          return fulfillment if line_item.sku == JOULE_SKU
        end
      end
      nil
    end

    def joule_line_item(shopify_order)
      shopify_order.line_items.each do |line_item|
        return line_item if line_item.sku == JOULE_SKU
      end
      raise "Order with id #{shopify_order.id} contains no Joule line item with sku #{JOULE_SKU}"
    end

    def sync_trackings_to_shopify(fulfillment)
      return if trackings.empty?

      if fulfillment.respond_to?(:tracking_numbers)
        fulfillment.tracking_numbers.clear
      else
        fulfillment.attributes[:tracking_numbers] = []
      end
      if fulfillment.respond_to?(:tracking_urls)
        fulfillment.tracking_urls.clear
      else
        fulfillment.attributes[:tracking_urls] = []
      end
      shopify_carrier = nil
      trackings.each do |tracking|
        # Shopify assumes all shipments in a fulfillment are done with the
        # same carrier, though Shipwire allows different carriers for each.
        # We set the Shopify carrier name to the first one here. Hard to imagine
        # we'd use different carriers for the same address, but the most
        # important thing is that we maintain a list of carrier-specific
        # tracking numbers and URLs.
        shopify_carrier = tracking.carrier unless shopify_carrier
        fulfillment.tracking_numbers << tracking.number
        fulfillment.tracking_urls << tracking.url
      end
      fulfillment.attributes[:carrier] = shopify_carrier
    end

    def sync_held_state_to_shopify(shopify_order)
      hold_tags = ['shipwire-held']
      holds.each do |hold|
        hold_tags << "shipwire-held-#{hold.type}-#{hold.sub_type}"
      end
      shopify_order.save if Shopify::Utils.add_to_order_tags(shopify_order, hold_tags)
    end

    def self.array_from_json(json_str)
      hash = JSON.parse(json_str)
      orders = []
      hash.fetch('resource').fetch('items').each do |order_hash|
        orders << from_hash(order_hash.fetch('resource'))
      end
      orders
    end
  end
end
