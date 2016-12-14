require 'spec_helper'

describe Fulfillment::PendingOrderExporter do
  describe 'transform' do
    let(:order_id) { '55555555' }
    let(:order_name) { '#12345678' }
    let(:processed_at) { Time.now.utc.iso8601.to_s }
    let(:company) { 'company' }
    let(:name) { 'name' }
    let(:address1) { 'address1' }
    let(:address2) { 'address2' }
    let(:city) { 'city' }
    let(:province_code) { 'XY' }
    let(:zip) { '12345' }
    let(:country_code) { 'US' }
    let(:phone) { '555-555-5555' }
    let(:line_item_id_1) { '1111' }
    let(:sku_1) { 'sku-1' }
    let(:quantity_1) { 1 }
    let(:line_item_id_2) { '2222' }
    let(:sku_2) { 'sku-1' }
    let(:quantity_2) { 2 }
    let(:fulfillable) do
      Fulfillment::Fulfillable.new(
        order: ShopifyAPI::Order.new(
          id: order_id,
          name: order_name,
          processed_at: processed_at,
          shipping_address: {
            company: company,
            name: name,
            address1: address1,
            address2: address2,
            city: city,
            province_code: province_code,
            zip: zip,
            country_code: country_code,
            phone: phone
          }
        ),
        line_items: [
          ShopifyAPI::LineItem.new(
            id: line_item_id_1,
            sku: sku_1,
            fulfillable_quantity: quantity_1
          ),
          ShopifyAPI::LineItem.new(
            id: line_item_id_2,
            sku: sku_2,
            fulfillable_quantity: quantity_2
          )
        ]
      )
    end

    it 'transforms fulfillable line items into columns' do
      expect(Fulfillment::PendingOrderExporter.transform(fulfillable)).to eq(
        [
          [
            order_id,
            order_name,
            line_item_id_1,
            processed_at,
            company,
            name,
            address1,
            address2,
            city,
            province_code,
            zip,
            country_code,
            phone,
            sku_1,
            quantity_1
          ],
          [
            order_id,
            order_name,
            line_item_id_2,
            processed_at,
            company,
            name,
            address1,
            address2,
            city,
            province_code,
            zip,
            country_code,
            phone,
            sku_2,
            quantity_2
          ]
        ]
      )
    end
  end
end
