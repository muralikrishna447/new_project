module Fulfillment
  class Shipment
    attr_reader :order

    attr_reader :fulfillments

    attr_reader :tracking_company

    attr_reader :tracking_numbers

    attr_reader :serial_numbers

    attr_reader :shipped_on_dates

    def initialize(params = {})
      @order = params[:order]
      @fulfillments = params[:fulfillments]
      @tracking_company = params[:tracking_company]
      @tracking_numbers = params[:tracking_numbers]
      @serial_numbers = params[:serial_numbers]
      @shipped_on_dates = params[:shipped_on_dates]
    end

    def ==(other)
      return false if order != other.order
      return false if fulfillments != other.fulfillments
      return false if tracking_company != other.tracking_company
      return false if tracking_numbers != other.tracking_numbers
      return false if serial_numbers != other.serial_numbers
      return false if shipped_on_dates != other.shipped_on_dates
      true
    end
  end
end
