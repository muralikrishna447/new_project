module Fulfillment
  class Shipment
    attr_reader :order

    attr_reader :fulfillments

    attr_reader :tracking_company

    attr_reader :tracking_numbers

    attr_reader :serial_numbers

    def initialize(params = {})
      @order = params[:order]
      @fulfillments = params[:fulfillments]
      @tracking_company = params[:tracking_company]
      @tracking_numbers = params[:tracking_numbers]
      @serial_numbers = params[:serial_numbers]
    end

    def ==(other)
      return false if order != other.order
      return false if fulfillments != other.fulfillments
      return false if tracking_company != other.tracking_company
      return false if tracking_numbers != other.tracking_numbers
      return false if serial_numbers != other.serial_numbers
      true
    end
  end
end
