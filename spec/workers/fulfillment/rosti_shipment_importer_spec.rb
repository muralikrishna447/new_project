require 'spec_helper'

describe Fulfillment::RostiShipmentImporter do
  describe 'job_params' do
    shared_examples 's3' do
      let(:s3_bucket) { 'my_s3_bucket' }
      let(:s3_region) { 'my_s3_region' }
      before :each do
        Fulfillment::RostiShipmentImporter.configure(
          s3_bucket: s3_bucket,
          s3_region: s3_region
        )
      end

      it 'adds bucket and region to job params' do
        expect(Fulfillment::RostiShipmentImporter.job_params({})).to eq(
          headers: true,
          storage: 's3',
          storage_s3_bucket: s3_bucket,
          storage_s3_region: s3_region
        )
      end
    end

    context 'storage is s3' do
      let(:storage) { 's3' }
      include_examples 's3'
    end

    context 'storage is not specified' do
      let(:storage) { nil }
      include_examples 's3'
    end

    context 'storage is not s3' do
      let(:storage) { 'other_storage' }
      it 'returns expected params' do
        expect(Fulfillment::RostiShipmentImporter.job_params(storage: storage)).to eq(
          headers: true,
          storage: storage
        )
      end
    end
  end

  describe 'to_shipment' do
    let(:order_name) { '123' }
    let(:line_item_id) { '456' }
    let(:order_number) { "##{order_name}-#{line_item_id}" }
    let(:serial_number) { '9999999' }
    let(:tracking_number) { '7777777' }
    let(:csv_row) do
      {
        'order_number' => order_number,
        'TRAN' => serial_number,
        'CRN' => tracking_number
      }
    end

    shared_examples 'exception' do
      it 'raises exception' do
        expect { Fulfillment::RostiShipmentImporter.to_shipment(csv_row) }.to raise_error
      end
    end

    context 'csv row is not valid' do
      context 'order number column is empty' do
        let(:order_number) { '' }
        include_examples 'exception'
      end

      context 'order number column has invalid format' do
        let(:order_number) { '123-456' }
        include_examples 'exception'
      end

      context 'tracking number column is empty' do
        let(:tracking_number) { '' }
        include_examples 'exception'
      end
    end

    context 'csv row is valid' do
      before :each do
        Shopify::Utils.should_receive(:order_by_name).with(order_name).and_return(order)
      end

      context 'shopify order does not exist' do
        let(:order) { nil }
        include_examples 'exception'
      end

      context 'shopify order exists' do
        let(:order) { ShopifyAPI::Order.new(id: 1, name: order_name) }
        let(:fulfillments) do
          [
            ShopifyAPI::Fulfillment.new(id: 11),
            ShopifyAPI::Fulfillment.new(id: 22)
          ]
        end
        it 'returns shipment' do
          Fulfillment::RostiShipmentImporter.should_receive(:fulfillments).with(order, [line_item_id]).and_return(fulfillments)
          expect(Fulfillment::RostiShipmentImporter.to_shipment(csv_row)).to eq(
            Fulfillment::Shipment.new(
              order: order,
              fulfillments: fulfillments,
              tracking_company: 'FedEx',
              tracking_numbers: [tracking_number],
              serial_numbers: [serial_number]
            )
          )
        end
      end
    end
  end
end
