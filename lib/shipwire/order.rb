module Shipwire
  class Order
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
      Rails.logger.info "Starting sync for Shopify order id #{shopify_order.id} and Shipwire order id #{id}"
      validate_sync(shopify_order)

      shopify_fulfillment = joule_fulfillment(shopify_order)
      if shopify_fulfillment
        Rails.logger.info "Found existing Joule fulfillment with id #{shopify_fulfillment.id} for Shopify order with id #{shopify_order.id}, will update it"
        handle_existing_fulfillment(shopify_fulfillment)
      else
        Rails.logger.info "No Joule fulfillment exists for Shopify order with id #{shopify_order.id}, will create one"
        handle_new_fulfillment(shopify_order)
      end

      # Lastly we add tags to the Shopify order if Shipwire held it.
      if fulfillment_held?
        Rails.logger.info "Shopify order with id #{shopify_order.id} has a hold in Shipwire order with id #{id}"
        save_held_state_to_shopify(shopify_order)
      end
    end

    def update_shopify_trackings(fulfillment)
      return false if trackings.empty?

      unless fulfillment.respond_to?(:tracking_numbers)
        fulfillment.attributes[:tracking_numbers] = []
      end
      unless fulfillment.respond_to?(:tracking_urls)
        fulfillment.attributes[:tracking_urls] = []
      end
      shopify_carrier = nil
      modified = false
      shipwire_tracking_numbers = []
      shipwire_tracking_urls = []
      trackings.each do |tracking|
        # Shopify assumes all shipments in a fulfillment are done with the
        # same carrier, though Shipwire allows different carriers for each.
        # We set the Shopify carrier name to the first one here. Hard to imagine
        # we'd use different carriers for the same address, but the most
        # important thing is that we maintain a list of carrier-specific
        # tracking numbers and URLs.
        shopify_carrier = tracking.carrier unless shopify_carrier
        shipwire_tracking_numbers << tracking.number if tracking.number
        shipwire_tracking_urls << tracking.url if tracking.url
      end

      if fulfillment.tracking_numbers.sort != shipwire_tracking_numbers.sort && !shipwire_tracking_numbers.empty?
        modified = true
        fulfillment.tracking_numbers = shipwire_tracking_numbers
      end
      if fulfillment.tracking_urls.sort != shipwire_tracking_urls.sort && !shipwire_tracking_urls.empty?
        modified = true
        fulfillment.tracking_urls = shipwire_tracking_urls
      end

      if fulfillment.attributes[:tracking_company] != shopify_carrier
        modified = true
        fulfillment.attributes[:tracking_company] = shopify_carrier
      end

      if modified
        Rails.logger.info "Updating tracking for Shopify fulfillment with id #{fulfillment.id} with carrier #{shopify_carrier}, tracking numbers #{fulfillment.tracking_numbers.inspect}, tracking URLs #{fulfillment.tracking_urls.inspect}"
      else
        Rails.logger.info "No changes in tracking for Shopify fulfillment with id #{fulfillment.id}, not updating"
      end
      modified
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
          return fulfillment if line_item.sku == Shopify::Order::JOULE_SKU
        end
      end
      nil
    end

    def handle_existing_fulfillment(fulfillment)
      fulfillment.save if update_shopify_trackings(fulfillment)

      # Don't complete the fulfillment if it has already been completed.
      return if fulfillment.status == 'success'

      if fulfillment_complete?
        Rails.logger.info "Completing Shopify fulfillment with id #{fulfillment.id}, Shipwire status for order with id #{id} is #{status}"
        fulfillment.complete
      else
        Rails.logger.info "Shopify fulfillment with id #{fulfillment.id} is not complete, Shipwire status for order with id #{id} is #{status}"
      end
    end

    def handle_new_fulfillment(shopify_order)
      shopify_fulfillment = ShopifyAPI::Fulfillment.new
      shopify_fulfillment.prefix_options[:order_id] = shopify_order.id
      shopify_fulfillment.attributes[:line_items] = [{ id: joule_line_item(shopify_order).id }]
      update_shopify_trackings(shopify_fulfillment)

      if fulfillment_complete?
        Rails.logger.info "Setting new fulfillment status to success for Shopify order with id #{shopify_order.id}, Shipwire status for order with id #{id} is #{status}"
        shopify_fulfillment.attributes[:status] = 'success'
      elsif fulfillment_pending? || fulfillment_held?
        Rails.logger.info "Setting new fulfillment status to open for Shopify order with id #{shopify_order.id}, Shipwire status for order with id #{id} is #{status}"
        shopify_fulfillment.attributes[:status] = 'open'
      end
      shopify_fulfillment.save
    end

    def joule_line_item(shopify_order)
      shopify_order.line_items.each do |line_item|
        return line_item if line_item.sku == Shopify::Order::JOULE_SKU
      end
      raise "Order with id #{shopify_order.id} contains no Joule line item with sku #{JOULE_SKU}"
    end

    def save_held_state_to_shopify(shopify_order)
      hold_tags = ['shipwire-held']
      holds.each do |hold|
        hold_tags << "shipwire-held-#{hold.type}-#{hold.sub_type}"
      end
      Rails.logger.info "Will update hold tags for Shopify order with id #{shopify_order.id} to include #{hold_tags.inspect}"
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
