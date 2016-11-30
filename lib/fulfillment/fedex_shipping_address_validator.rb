module Fulfillment
  class FedexShippingAddressValidator
    MIN_LINE_LENGTH = 3

    MAX_LINE_LENGTH = 35

    POBOX_REGEX = /^(?:Post(?:al)?\s*(?:Office\s*)?|P[. ]?\s*O\.?\s*)?Box\b/i

    US_MILITARY_STATES = %w(AA AE AP)

    US_TERRITORY_STATES = %w(AS FM GU MH MP PW PR VI)

    def self.valid?(order)
      return false if log_validation(
        order_id: order.id,
        condition: !order.respond_to?(:shipping_address),
        message: 'order has no shipping address'
      )

      # Name line is required and must be valid length
      return false if log_validation(
        order_id: order.id,
        condition: nil_or_empty?(order.shipping_address.name),
        message: 'name is empty or nil'
      )
      return false if log_validation(
        order_id: order.id,
        condition: invalid_length?(order.shipping_address.name),
        message: "name has invalid length: #{order.shipping_address.name}"
      )

      # Company line is optional and must be valid length
      return false if log_validation(
        order_id: order.id,
        condition: invalid_length?(order.shipping_address.company),
        message: "company has invalid length: #{order.shipping_address.company}"
      )

      # Address1 line is required and must be valid length
      return false if log_validation(
        order_id: order.id,
        condition: nil_or_empty?(order.shipping_address.address1),
        message: 'address1 is empty or nil'
      )
      return false if log_validation(
        order_id: order.id,
        condition: invalid_length?(order.shipping_address.address1),
        message: "address1 has invalid length: #{order.shipping_address.address1}"
      )

      # Address2 line is optional and must be valid length
      return false if log_validation(
        order_id: order.id,
        condition: exceeds_max_length?(order.shipping_address.address2),
        message: "address2 has invalid length: #{order.shipping_address.address2}"
      )

      # City is required and must be valid length
      return false if log_validation(
        order_id: order.id,
        condition: nil_or_empty?(order.shipping_address.city),
        message: 'city is nil or empty'
      )
      return false if log_validation(
        order_id: order.id,
        condition: invalid_length?(order.shipping_address.city),
        message: 'city has invalid length'
      )

      # State code is required and must be two characters in length
      return false if log_validation(
        order_id: order.id,
        condition: nil_or_empty?(order.shipping_address.province_code),
        message: 'province_code is nil or empty'
      )
      return false if log_validation(
        order_id: order.id,
        condition: order.shipping_address.province_code.length != 2,
        message: "province_code has invalid length: #{order.shipping_address.province_code}"
      )

      # Country code is required and must be two characters in length
      return false if log_validation(
        order_id: order.id,
        condition: nil_or_empty?(order.shipping_address.country_code),
        message: 'country_code is nil or empty'
      )
      return false if log_validation(
        order_id: order.id,
        condition: order.shipping_address.country_code.length != 2,
        message: "country_code has invalid length: #{order.shipping_address.country_code}"
      )

      # No PO boxes
      return false if log_validation(
        order_id: order.id,
        condition: order.shipping_address.address1 =~ POBOX_REGEX,
        message: "address1 looks like a PO Box: #{order.shipping_address.address1}"
      )
      return false if log_validation(
        order_id: order.id,
        condition: order.shipping_address.address2 =~ POBOX_REGEX,
        message: "address2 looks like a PO Box: #{order.shipping_address.address2}"
      )

      # No APO/FPO/DPO military state codes
      return false if log_validation(
        order_id: order.id,
        condition: US_MILITARY_STATES.include?(order.shipping_address.province_code),
        message: "province_code is US military: #{order.shipping_address.province_code}"
      )

      # No US territory state codes
      return false if log_validation(
        order_id: order.id,
        condition: US_TERRITORY_STATES.include?(order.shipping_address.province_code),
        message: "province_code is US military: #{order.shipping_address.province_code}"
      )

      Rails.logger.info("FedEx address validator order with id #{order.id} is valid")
      true
    end

    private

    def self.nil_or_empty?(prop)
      prop.nil? || prop.empty?
    end

    def self.invalid_length?(prop)
      return false if nil_or_empty?(prop)
      return true if prop.length > MAX_LINE_LENGTH
      return true if prop.length < MIN_LINE_LENGTH
      false
    end

    def self.exceeds_max_length?(prop)
      return false if nil_or_empty?(prop)
      return true if prop.length > MAX_LINE_LENGTH
      false
    end

    def self.log_validation(params)
      if params[:condition]
        Rails.logger.info("FedEx address validator order with id #{params[:order_id]} is invalid because #{params[:message]}")
      end
      params[:condition]
    end
  end
end
