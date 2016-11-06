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
    let(:rosti_order_number) { "##{order_name}-#{line_item_id}" }
    let(:serial_number_1) { 'serial_number_1' }
    let(:tracking_number_1) { 'tracking_number_1' }
    let(:csv_row_1) do
      {
        'order_number' => rosti_order_number,
        'TRAN' => serial_number_1,
        'CRN' => tracking_number_1
      }
    end
    let(:csv_rows) { [csv_row_1] }

    shared_examples 'exception' do
      it 'raises exception' do
        expect { Fulfillment::RostiShipmentImporter.to_shipments(csv_rows) }.to raise_error
      end
    end

    context 'csv row is not valid' do
      context 'order number column is empty' do
        let(:rosti_order_number) { '' }
        include_examples 'exception'
      end

      context 'order number column has invalid format' do
        let(:rosti_order_number) { '123-456' }
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

        context 'csv has single row for line item' do
          it 'returns shipment with single tracking number and serial number' do
            Fulfillment::RostiShipmentImporter.should_receive(:fulfillments).with(order, [line_item_id]).and_return(fulfillments)
            expect(Fulfillment::RostiShipmentImporter.to_shipments(csv_rows)).to match_array(
              [
                Fulfillment::Shipment.new(
                  order: order,
                  fulfillments: fulfillments,
                  tracking_company: 'FedEx',
                  tracking_numbers: [tracking_number_1],
                  serial_numbers: [serial_number_1]
                )
              ]
            )
          end
        end

        context 'csv has multiple rows for line item' do
          let(:serial_number_2) { 'serial_number_2' }
          let(:tracking_number_2) { 'tracking_number_2' }
          let(:csv_row_2) do
            {
              'order_number' => rosti_order_number,
              'TRAN' => serial_number_2,
              'CRN' => tracking_number_2
            }
          end
          let(:csv_rows) { [csv_row_1, csv_row_2] }

          it 'returns shipment with multiple tracking numbers and serial numbers' do
            Fulfillment::RostiShipmentImporter.should_receive(:fulfillments).with(order, [line_item_id]).and_return(fulfillments)
            expect(Fulfillment::RostiShipmentImporter.to_shipments(csv_rows)).to match_array(
              [
                Fulfillment::Shipment.new(
                  order: order,
                  fulfillments: fulfillments,
                  tracking_company: 'FedEx',
                  tracking_numbers: [tracking_number_1, tracking_number_2],
                  serial_numbers: [serial_number_1, serial_number_2]
                )
              ]
            )
          end
        end
      end
    end
  end
end
