require 'spec_helper'

describe Fulfillment::RostiOrderExporter do
  describe 'perform' do
    before do
      Timecop.freeze(Time.now)
    end
    after do
      Timecop.return
    end

    context 'storage is s3' do
      let(:s3_bucket) { 'my s3 bucket' }
      let(:s3_region) { 'my s3 region' }

      it 'calls inner_perform' do
        Fulfillment::RostiOrderExporter.configure(
          s3_bucket: s3_bucket,
          s3_region: s3_region
        )
        params = { storage: 's3' }
        Fulfillment::RostiOrderExporter.should_receive(:inner_perform).with(
          params.merge(
            storage: 's3',
            storage_s3_bucket: s3_bucket,
            storage_s3_region: s3_region,
            storage_filename: "#{Fulfillment::RostiOrderExporter.type}-#{Time.now.utc.iso8601}.csv",
            skus: [Shopify::Order::JOULE_SKU]
          )
        )
        Fulfillment::RostiOrderExporter.perform(params)
      end
    end

    context 'storage is file' do
      it 'calls inner_perform' do
        params = { storage: 'file' }
        Fulfillment::RostiOrderExporter.should_receive(:inner_perform).with(
          params.merge(
            storage_filename: "#{Fulfillment::RostiOrderExporter.type}-#{Time.now.utc.iso8601}.csv",
            skus: [Shopify::Order::JOULE_SKU]
          )
        )
        Fulfillment::RostiOrderExporter.perform(params)
      end
    end
  end

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
            quantity: quantity_1
          ),
          ShopifyAPI::LineItem.new(
            id: line_item_id_2,
            sku: sku_2,
            quantity: quantity_2
          )
        ]
      )
    end

    it 'transforms fulfillable line items into columns' do
      expect(Fulfillment::RostiOrderExporter.transform(fulfillable)).to match_array(
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
            Fulfillment::RostiOrderExporter::RETURN_NAME,
            Fulfillment::RostiOrderExporter::RETURN_COMPANY,
            Fulfillment::RostiOrderExporter::RETURN_ADDRESS_1,
            Fulfillment::RostiOrderExporter::RETURN_ADDRESS_2,
            Fulfillment::RostiOrderExporter::RETURN_CITY,
            Fulfillment::RostiOrderExporter::RETURN_STATE,
            Fulfillment::RostiOrderExporter::RETURN_ZIP,
            Fulfillment::RostiOrderExporter::RETURN_COUNTRY
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
            Fulfillment::RostiOrderExporter::RETURN_NAME,
            Fulfillment::RostiOrderExporter::RETURN_COMPANY,
            Fulfillment::RostiOrderExporter::RETURN_ADDRESS_1,
            Fulfillment::RostiOrderExporter::RETURN_ADDRESS_2,
            Fulfillment::RostiOrderExporter::RETURN_CITY,
            Fulfillment::RostiOrderExporter::RETURN_STATE,
            Fulfillment::RostiOrderExporter::RETURN_ZIP,
            Fulfillment::RostiOrderExporter::RETURN_COUNTRY
          ]
        ]
      )
    end
  end
end
