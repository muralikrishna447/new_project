# encoding: UTF-8
require 'spec_helper'
require 'fulfillment/order_search_provider'

describe Fulfillment::OrderCleaners do
  let(:exporter) { Class.new { include Fulfillment::CSVOrderExporter } }

  describe 'clean!' do

    let(:ok_order) do
      order = ShopifyAPI::Order.new(
          name: 'OK_ORDER',
          processed_at: Time.now,
          shipping_address: {
              company: ok_company,
              name: ok_name,
              address1: ok_address1,
              address2: ok_address2,
              city: ok_city,
              province_code: ok_province_code,
              zip: ok_zip,
              country_code: ok_country_code,
              phone: ok_phone
          }
      )
      order.id = 1
      order.line_items = [ok_order_line_item_1, ok_order_line_item_2]
      order
    end
    let(:ok_order_line_item_1) { ShopifyAPI::LineItem.new(id: 111) }
    let(:ok_order_line_item_2) { ShopifyAPI::LineItem.new(id: 112) }

    let(:ok_company){ 'OK COMPANY' }
    let(:ok_name){ 'OK NAME' }
    let(:ok_address1){ 'OK ADDRESS1' }
    let(:ok_address2){ 'OK ADDRESS2' }
    let(:ok_city){ 'OK CITY' }
    let(:ok_province_code){ 'OK PROVINCE' }
    let(:ok_zip){ 'OK ZIP' }
    let(:ok_country_code){ 'OK COUNTRY' }
    let(:ok_phone){ '206 555 5555' }



    let(:accented_company){ 'ÔK COMPÀNY' }
    let(:accented_name){ 'ÖK NÁME' }
    let(:accented_address1){ 'ÒK ÂDDRÈSS1' }
    let(:accented_address2){ 'ÓK ÄDDRÉSS2' }
    let(:accented_city){ 'ÕK CITY' }
    let(:accented_province_code){ 'ØK PROVINCË' }
    let(:accented_zip){ 'ŌK ZÎP' }
    let(:accented_country_code){ 'ÕK COÜNTRY' }
    let(:accented_phone){ '206 555 5555' }


    let(:accented_order) do
      order = ShopifyAPI::Order.new(
          name: 'ACCENTED_ORDER',
          processed_at: Time.now,
          shipping_address: {
              company: accented_company,
              name: accented_name,
              address1: accented_address1,
              address2: accented_address2,
              city: accented_city,
              province_code: accented_province_code,
              zip: accented_zip,
              country_code: accented_country_code,
              phone: accented_phone
          }
      )
      order.id = 2
      order.line_items = [ok_order_line_item_1, ok_order_line_item_2]
      order
    end


    it 'calls all the configured cleaners' do
      Fulfillment::OrderCleaners::RemoveAccentedCharacters.should_receive(:clean!).with(ok_order)
      subject.clean!(ok_order)
    end

    it 'does not change unaccented orders' do
      subject.clean!(ok_order)
      expect(ok_order.shipping_address.company).to eq(ok_company)
      expect(ok_order.shipping_address.name).to eq(ok_name)
      expect(ok_order.shipping_address.address1).to eq(ok_address1)
      expect(ok_order.shipping_address.address2).to eq(ok_address2)
      expect(ok_order.shipping_address.city).to eq(ok_city)
      expect(ok_order.shipping_address.province_code).to eq(ok_province_code)
      expect(ok_order.shipping_address.zip).to eq(ok_zip)
      expect(ok_order.shipping_address.country_code).to eq(ok_country_code)
      expect(ok_order.shipping_address.phone).to eq(ok_phone)
    end

    it 'changes accented characters in orders' do
      subject.clean!(accented_order)
      expect(accented_order.shipping_address.company).to eq(ok_company)
      expect(accented_order.shipping_address.name).to eq(ok_name)
      expect(accented_order.shipping_address.address1).to eq(ok_address1)
      expect(accented_order.shipping_address.address2).to eq(ok_address2)
      expect(accented_order.shipping_address.city).to eq(ok_city)
      expect(accented_order.shipping_address.province_code).to eq(ok_province_code)
      expect(accented_order.shipping_address.zip).to eq(ok_zip)
      expect(accented_order.shipping_address.country_code).to eq(ok_country_code)
      expect(accented_order.shipping_address.phone).to eq(ok_phone)
    end

  end
end
