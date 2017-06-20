module Fulfillment
  class FedexShippingAddressValidator
    MIN_LINE_LENGTH = 3

    MAX_LINE_LENGTH = 35

    POBOX_REGEX = /^(?:Post(?:al)?\s*(?:Office\s*)?|P[. ]?\s*O\.?\s*)?Box\b/i

    US_MILITARY_STATES = %w(AA AE AP)

    US_TERRITORY_STATES = %w(AS FM GU MH MP PW PR VI)

    def self.valid?(order)
      validate(order)[:is_valid]
    end

    def self.validate(order)
      validation = log_validation(
        order_id: order.id,
        condition: !order.respond_to?(:shipping_address),
        message: 'order has no shipping address'
      )
      return validation unless validation[:is_valid]

      multi_validations(order).each do |params|
        validation = send(:any_invalid?, params)
        return validation unless validation[:is_valid]
      end

      single_validations(order).each do |params|
        validation = send(:log_validation, params)
        return validation unless validation[:is_valid]
      end

      Rails.logger.info("FedEx address validator order with id #{order.id} is valid")
      { is_valid: true, messages: [] }
    end

    private

    def self.any_invalid?(params)
      invalid = false
      messages = []
      params[:properties].each do |prop|
        message = "#{prop}: #{params[:message]}"
        validation = log_validation(
          order_id: params[:order].id,
          condition: FedexShippingAddressValidator.send(
            params[:validation_method],
            params[:order].shipping_address.send(prop)
          ),
          message: message
        )
        unless validation[:is_valid]
          invalid = true
          messages << message
        end
      end
      { is_valid: !invalid, messages: messages }
    end

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

    # We can only handle ASCII printable characters within codepoints 32-126.
    def self.contains_invalid_char?(prop)
      return false if nil_or_empty?(prop)
      return true if prop.include?('"')
      prop.each_codepoint { |c| return true if c < 32 || c > 126 }
      false
    end

    def self.log_validation(params)
      if params[:condition]
        Rails.logger.warn("FedEx address validator order with id #{params[:order_id]} is invalid because #{params[:message]}")
        return { is_valid: false, messages: [params[:message]] }
      end
      { is_valid: true, messages: [] }
    end

    def self.multi_validations(order)
      [
        {
          order: order,
          validation_method: :nil_or_empty?,
          message: 'nil or empty',
          properties: [
            :name,
            :address1,
            :city,
            :province_code,
            :country_code
          ]
        },
        {
          order: order,
          validation_method: :invalid_length?,
          message: "invalid length, must be between #{MIN_LINE_LENGTH} and #{MAX_LINE_LENGTH} characters",
          properties: [
            :name,
            :company,
            :address1,
            :city
          ]
        },
        {
          order: order,
          validation_method: :exceeds_max_length?,
          message: "exceeds max length, must be #{MAX_LINE_LENGTH} characters or less",
          properties: [:address2]
        },
        {
          order: order,
          validation_method: :contains_invalid_char?,
          message: 'contains invalid character',
          properties: [
            :name,
            :company,
            :address1,
            :address2,
            :city,
            :phone
          ]
        }
      ]
    end

    def self.single_validations(order)
      [
        {
          order_id: order.id,
          condition: order.shipping_address.province_code.length != 2,
          message: "province_code has invalid length: #{order.shipping_address.province_code}"
        },
        {
          order_id: order.id,
          condition: order.shipping_address.country_code.length != 2,
          message: "country_code has invalid length: #{order.shipping_address.country_code}"
        },
        {
          order_id: order.id,
          condition: order.shipping_address.address1 =~ POBOX_REGEX,
          message: "address1 looks like a PO Box: #{order.shipping_address.address1}"
        },
        {
          order_id: order.id,
          condition: order.shipping_address.address2 =~ POBOX_REGEX,
          message: "address2 looks like a PO Box: #{order.shipping_address.address2}"
        },
        {
          order_id: order.id,
          condition: US_MILITARY_STATES.include?(order.shipping_address.province_code),
          message: "province_code is US military: #{order.shipping_address.province_code}"
        },
        {
          order_id: order.id,
          condition: US_TERRITORY_STATES.include?(order.shipping_address.province_code),
          message: "province_code is US military: #{order.shipping_address.province_code}"
        }
      ]
    end
  end
end
