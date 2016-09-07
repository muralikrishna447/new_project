module Shipwire
  class Order
    # Shipwire's unique order ID
    attr_reader :id

    # Shipwire's order status (e.g., submitted, processing, completed, delivered)
    attr_reader :status

    # Array of Shipwire::Tracking
    attr_reader :trackings

    def initialize(params = {})
      @id = params[:id]
      @status = params[:status]
      @trackings = params[:trackings]
    end

    def self.array_from_json(json_str)
      hash = JSON.parse(json_str)
      orders = []
      hash.fetch('resource').fetch('items').each do |order_hash|
        orders << from_hash(order_hash.fetch('resource'))
      end
      orders
    end

    def ==(other)
      id == other.id && status == other.status && trackings == other.trackings
    end

    private_class_method
    def self.from_hash(order_hash)
      Shipwire::Order.new(
        id: order_hash.fetch('id'),
        status: order_hash.fetch('status'),
        trackings: Shipwire::Tracking.array_from_hash(order_hash.fetch('trackings'))
      )
    end
  end
end
