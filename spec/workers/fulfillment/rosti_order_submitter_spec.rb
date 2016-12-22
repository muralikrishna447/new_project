require 'spec_helper'

describe Fulfillment::RostiOrderSubmitter do
  describe 'transform' do
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
      expect(Fulfillment::RostiOrderSubmitter.transform(fulfillable)).to eq(
        [
          [
            "#{order_name}-#{line_item_id_1}",
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
            quantity_1,
            Fulfillment::RostiOrderSubmitter::RETURN_NAME,
            Fulfillment::RostiOrderSubmitter::RETURN_COMPANY,
            Fulfillment::RostiOrderSubmitter::RETURN_ADDRESS_1,
            Fulfillment::RostiOrderSubmitter::RETURN_ADDRESS_2,
            Fulfillment::RostiOrderSubmitter::RETURN_CITY,
            Fulfillment::RostiOrderSubmitter::RETURN_STATE,
            Fulfillment::RostiOrderSubmitter::RETURN_ZIP,
            Fulfillment::RostiOrderSubmitter::RETURN_COUNTRY
          ],
          [
            "#{order_name}-#{line_item_id_2}",
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
            quantity_2,
            Fulfillment::RostiOrderSubmitter::RETURN_NAME,
            Fulfillment::RostiOrderSubmitter::RETURN_COMPANY,
            Fulfillment::RostiOrderSubmitter::RETURN_ADDRESS_1,
            Fulfillment::RostiOrderSubmitter::RETURN_ADDRESS_2,
            Fulfillment::RostiOrderSubmitter::RETURN_CITY,
            Fulfillment::RostiOrderSubmitter::RETURN_STATE,
            Fulfillment::RostiOrderSubmitter::RETURN_ZIP,
            Fulfillment::RostiOrderSubmitter::RETURN_COUNTRY
          ]
        ]
      )
    end
  end

  describe 'after_save' do
    let(:fulfillable_1_quantity) { 1 }
    let(:fulfillable_2_quantity) { 2 }
    let(:total_quantity) { fulfillable_1_quantity + fulfillable_2_quantity }
    let(:fulfillable_1) do
      fulfillable = double('fulfillable-1')
      fulfillable.stub(:quantity) { fulfillable_1_quantity }
      fulfillable
    end
    let(:fulfillable_2) do
      fulfillable = double('fulfillable-2').stub(:quantity)
      fulfillable.stub(:quantity) { fulfillable_2_quantity }
      fulfillable
    end
    let(:fulfillables) { [fulfillable_1, fulfillable_2] }
    it 'reports metrics' do
      Librato.should_receive(:increment).with('fulfillment.rosti.order-submitter.success', sporadic: true)
      Librato.should_receive(:increment).with('fulfillment.rosti.order-submitter.count', by: fulfillables.length, sporadic: true)
      Librato.should_receive(:increment).with('fulfillment.rosti.order-submitter.quantity', by: total_quantity, sporadic: true)
      Fulfillment::RostiOrderSubmitter.after_save(fulfillables, {})
    end
  end
end
