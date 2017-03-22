require 'i18n'

module Fulfillment
  module OrderCleaners

    def self.clean!(order)
      ALL.each do | cleaner |
        cleaner.clean!(order)
      end
    end

    module RemoveAccentedCharacters
      SHIPPING_ADDRESS_FIELDS = %w(company name address1 address2 city province_code zip country_code phone)

      def self.clean!(order)
        if order.shipping_address?
          clean_shipping_address! order.shipping_address
        end
      end

      def self.clean_shipping_address!(shipping_address)
        begin
          SHIPPING_ADDRESS_FIELDS.each do |field|
            if shipping_address.send("#{field}?".to_sym)
              source = shipping_address.send(field.to_sym)
              cleaned = I18n.transliterate(source) unless source.nil?
              shipping_address.send("#{field}=".to_sym, cleaned)
            end
          end
        rescue StandardError => error
          Rails.logger.error("OrderCleaners::RemoveAccentedCharacters #{error.message}")
          Rails.logger.error("OrderCleaners::RemoveAccentedCharacters #{error.backtrace}")
          raise
        end

      end

    end

    ALL = [ RemoveAccentedCharacters ]
  end
end