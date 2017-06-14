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

    def complete!
      fulfillments.each do |fulfillment|
        update_tracking(fulfillment)
        complete_fulfillment(fulfillment)
      end
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

    private

    def update_tracking(fulfillment)
      if tracking_updated?(fulfillment)
        Rails.logger.info('Shipment tracking was already updated for order with id ' \
                          "#{order.id}, name #{order.name} and fulfillment " \
                          "with id #{fulfillment.id}: #{tracking_company} #{tracking_numbers}")
        return
      end

      Rails.logger.info('Shipment updating tracking for order with id ' \
                        "#{order.id}, name #{order.name} and fulfillment " \
                        "with id #{fulfillment.id}: #{tracking_company} #{tracking_numbers}")
      fulfillment.attributes[:tracking_company] = tracking_company
      fulfillment.attributes[:tracking_numbers] = tracking_numbers
      # We don't want to notify the customer here b/c it sends a shipment
      # update email instead of a shipment confirmation email and you
      # cannot update tracking and complete a fulfillment in a single call.
      fulfillment.attributes[:notify_customer] = false
      Shopify::Utils.send_assert_true(fulfillment, :save)
    end

    def complete_fulfillment(fulfillment)
      Rails.logger.info("Shipment completing fulfillment for order with id " \
                        "#{order.id}, name #{order.name} and fulfillment with id #{fulfillment.id}")
      # We have to set this and save it back to Shopify so that Shopify
      # will send a shipment confirmation email on completion.
      fulfillment.attributes[:notify_customer] = true
      Shopify::Utils.send_assert_true(fulfillment, :save)
      Shopify::Utils.send_assert_true(fulfillment, :complete)
    end

    def tracking_updated?(fulfillment)
      fulfillment.attributes[:tracking_company] == tracking_company &&
        (fulfillment.attributes[:tracking_numbers] || []).sort == (tracking_numbers || []).sort
    end
  end
end
