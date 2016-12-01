require 'spec_helper'

describe Fulfillment::FedexShippingAddressValidator do
  describe 'valid?' do
    let(:name) { 'Homer J. Simpson' }
    let(:company) { 'Mr. Plow' }
    let(:address1) { '123 Pleasant Lane' }
    let(:address2) { nil }
    let(:city) { 'Springfield' }
    let(:province_code) { 'OR' }
    let(:country_code) { 'US' }
    let(:phone) { '555-555-5555' }
    let(:order) do
      ShopifyAPI::Order.new(
        shipping_address: {
          name: name,
          company: company,
          address1: address1,
          address2: address2,
          city: city,
          province_code: province_code,
          country_code: country_code,
          phone: phone
        }
      )
    end
    let(:too_long) { '123456789012345678901234567890123456' }
    let(:too_short) { '12' }
    let(:invalid_char) { "ABC123\u{00A0}456" } # Non-breaking space, a common bad one

    shared_examples 'invalid' do
      it 'returns false' do
        expect(Fulfillment::FedexShippingAddressValidator.valid?(order)).to be_false
      end
    end

    context 'order has no shipping address' do
      let(:order) { ShopifyAPI::Order.new }
      include_examples 'invalid'
    end

    context 'order has no name' do
      let(:name) { nil }
      include_examples 'invalid'
    end

    context 'order has empty name' do
      let(:name) { '' }
      include_examples 'invalid'
    end

    context 'order has name less than min length' do
      let(:name) { too_short }
      include_examples 'invalid'
    end

    context 'order has name exceeding max length' do
      let(:name) { too_long }
      include_examples 'invalid'
    end

    context 'order has name with invalid char' do
      let(:name) { invalid_char }
      include_examples 'invalid'
    end

    context 'order has company less than min length' do
      let(:company) { too_short }
      include_examples 'invalid'
    end

    context 'order has company exceeding max length' do
      let(:company) { too_long }
      include_examples 'invalid'
    end

    context 'order has company with invalid char' do
      let(:company) { invalid_char }
      include_examples 'invalid'
    end

    context 'order has no address1' do
      let(:address1) { nil }
      include_examples 'invalid'
    end

    context 'order has empty address1' do
      let(:address1) { '' }
      include_examples 'invalid'
    end

    context 'order has address1 less than min length' do
      let(:address1) { too_short }
      include_examples 'invalid'
    end

    context 'order has address1 exceeding max length' do
      let(:address1) { too_long }
      include_examples 'invalid'
    end

    context 'order has address1 with invalid char' do
      let(:address1) { invalid_char }
      include_examples 'invalid'
    end

    context 'order has address2 exceeding max length' do
      let(:address2) { too_long }
      include_examples 'invalid'
    end

    context 'order has address2 with invalid char' do
      let(:address2) { invalid_char }
      include_examples 'invalid'
    end

    context 'order has no city' do
      let(:city) { nil }
      include_examples 'invalid'
    end

    context 'order has empty city' do
      let(:city) { '' }
      include_examples 'invalid'
    end

    context 'order has city less than min length' do
      let(:city) { too_short }
      include_examples 'invalid'
    end

    context 'order has city exceeding max length' do
      let(:city) { too_long }
      include_examples 'invalid'
    end

    context 'order has city with invalid char' do
      let(:city) { invalid_char }
      include_examples 'invalid'
    end

    context 'order has no province code' do
      let(:province_code) { nil }
      include_examples 'invalid'
    end

    context 'order has empty province code' do
      let(:province_code) { '' }
      include_examples 'invalid'
    end

    context 'order has province code with incorrect length' do
      let(:province_code) { 'XYZ' }
      include_examples 'invalid'
    end

    context 'order has no country code' do
      let(:country_code) { nil }
      include_examples 'invalid'
    end

    context 'order has empty country code' do
      let(:country_code) { '' }
      include_examples 'invalid'
    end

    context 'order has country code with incorrect length' do
      let(:country_code) { 'XYZ' }
      include_examples 'invalid'
    end

    context 'order has phone with invalid char' do
      let(:phone) { invalid_char }
      include_examples 'invalid'
    end

    context 'order has address line with PO Box' do
      let(:po_boxes) do
        [
          'P.O. Box',
          'P.O Box',
          'PO. Box',
          'P.O.Box',
          'POBox',
          'Post Office Box',
          'Box',
          'P.O. Box X',
          'P.O Box X',
          'PO. Box X',
          'P.O.Box X',
          'POBox X',
          'Post Office Box X',
          'Box X'
        ]
      end

      context 'order has address1 with PO Box' do
        it 'returns false' do
          po_boxes.each do |po_box|
            order.shipping_address.address1 = po_box
            expect(Fulfillment::FedexShippingAddressValidator.valid?(order)).to be_false, po_box
          end
        end
      end

      context 'order has address2 with PO Box' do
        it 'returns false' do
          po_boxes.each do |po_box|
            order.shipping_address.address2 = po_box
            expect(Fulfillment::FedexShippingAddressValidator.valid?(order)).to be_false, po_box
          end
        end
      end
    end

    context 'order has US military address' do
      it 'returns false' do
        Fulfillment::FedexShippingAddressValidator::US_MILITARY_STATES.each do |state|
          order.shipping_address.province_code = state
          expect(Fulfillment::FedexShippingAddressValidator.valid?(order)).to be_false, state
        end
      end
    end

    context 'order has US territory address' do
      it 'returns false' do
        Fulfillment::FedexShippingAddressValidator::US_TERRITORY_STATES.each do |state|
          order.shipping_address.province_code = state
          expect(Fulfillment::FedexShippingAddressValidator.valid?(order)).to be_false, state
        end
      end
    end
  end
end
