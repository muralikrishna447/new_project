module Shipwire
  class Tracking
    # The actual tracking number for the order shipment
    attr_reader :number

    # The carrier of the shipment (e.g., 'USPS')
    attr_reader :carrier

    # A URL to view shipment tracking status
    attr_reader :url

    def initialize(params = {})
      @number = params[:number]
      @carrier = params[:carrier]
      @url = params[:url]
    end

    def self.array_from_hash(tracking_array_hash)
      trackings = []
      tracking_array_hash.fetch('resource').fetch('items').each do |tracking_hash|
        trackings << from_hash(tracking_hash.fetch('resource'))
      end
      trackings
    end

    def ==(other)
      number == other.number && carrier == other.carrier && url == other.url
    end

    private_class_method
    def self.from_hash(tracking_hash)
      Shipwire::Tracking.new(
        number: tracking_hash.fetch('tracking'),
        carrier: tracking_hash.fetch('carrier'),
        url: tracking_hash.fetch('url')
      )
    end
  end
end
