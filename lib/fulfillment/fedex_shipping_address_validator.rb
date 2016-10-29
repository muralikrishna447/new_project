module Fulfillment
  class FedexShippingAddressValidator
    MAX_LINE_LENGTH = 35

    POBOX_REGEX = /^(?:Post(?:al)?\s*(?:Office\s*)?|P[. ]?\s*O\.?\s*)?Box\b/i

    US_MILITARY_STATES = %w(AA AE AP)

    US_TERRITORY_STATES = %w(AS FM GU MH MP PW PR VI)

    def self.valid?(order)
      return false unless order.respond_to?(:shipping_address)

      # Name line is required and max length is 35 chars
      return false if nil_or_empty?(order.shipping_address.name)
      return false if exceeds_max_length?(order.shipping_address.name)

      # Company line is optional and max length is 35 chars
      return false if exceeds_max_length?(order.shipping_address.company)

      # Address1 line is required and max length is 35 chars
      return false if nil_or_empty?(order.shipping_address.address1)
      return false if exceeds_max_length?(order.shipping_address.address1)

      # Address2 line is optional and max length is 35 chars
      return false if exceeds_max_length?(order.shipping_address.address2)

      # No PO boxes
      return false if order.shipping_address.address1 =~ POBOX_REGEX
      return false if order.shipping_address.address2 =~ POBOX_REGEX

      # No APO/FPO/DPO military state codes
      return false if US_MILITARY_STATES.include?(order.shipping_address.province_code)

      # No US territory state codes
      return false if US_TERRITORY_STATES.include?(order.shipping_address.province_code)

      true
    end

    private

    def self.nil_or_empty?(prop)
      prop.nil? || prop.empty?
    end

    def self.exceeds_max_length?(prop)
      prop && prop.length > MAX_LINE_LENGTH
    end
  end
end
