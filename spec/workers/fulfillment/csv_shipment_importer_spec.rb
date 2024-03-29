require 'spec_helper'
require 'json'

describe Fulfillment::CSVShipmentImporter do
  let(:importer) { Class.new { include Fulfillment::CSVShipmentImporter } }

  describe 'fulfillments' do
    let(:order) do
      ShopifyAPI::Order.new(
        id: 1,
        fulfillments: order_fulfillments,
        name: '#myordername')
    end

    context 'no fulfillment exists for line item' do
      let(:order_fulfillments) { [] }
      it 'raises exception' do
        expect { importer.fulfillments(order, [1]) }.to raise_error
      end
    end

    context 'fulfillment exists for single line item' do
      let(:line_item_id) { 11 }
      let(:order_fulfillments) do
        [
          ShopifyAPI::Fulfillment.new(
            id: 111,
            line_items: [
              ShopifyAPI::LineItem.new(id: line_item_id)
            ],
            status: fulfillment_status
          )
        ]
      end

      context 'fulfillment for line item is complete' do
        let(:fulfillment_status) { 'success' }
        it 'does not return fulfillment' do
          expect(importer.fulfillments(order, [line_item_id])).to be_empty
        end
      end

      context 'fulfillment for line item is open' do
        let(:fulfillment_status) { 'open' }
        it 'returns the fulfillment' do
          expect(importer.fulfillments(order, [line_item_id])).to eq(order_fulfillments)
        end
      end
    end

    context 'open fulfillment exists for multiple line items' do
      let(:line_item_id_1) { 11 }
      let(:line_item_id_2) { 22 }
      let(:order_fulfillments) do
        [
          ShopifyAPI::Fulfillment.new(
            id: 111,
            line_items: [
              ShopifyAPI::LineItem.new(id: line_item_id_1),
              ShopifyAPI::LineItem.new(id: line_item_id_2)
            ],
            status: 'open'
          )
        ]
      end

      it 'returns the fulfillment' do
        expect(importer.fulfillments(order, [line_item_id_1, line_item_id_2])).to eq(order_fulfillments)
      end
    end

    context 'line items exist in different open fulfillments' do
      let(:line_item_id_1) { 11 }
      let(:line_item_id_2) { 22 }
      let(:order_fulfillments) do
        [
          ShopifyAPI::Fulfillment.new(
            id: 111,
            line_items: [
              ShopifyAPI::LineItem.new(id: line_item_id_1)
            ],
            status: 'open'
          ),
          ShopifyAPI::Fulfillment.new(
            id: 222,
            line_items: [
              ShopifyAPI::LineItem.new(id: line_item_id_2)
            ],
            status: 'open'
          )
        ]
      end

      it 'returns the fulfillments' do
        expect(importer.fulfillments(order, [line_item_id_1, line_item_id_2])).to eq(order_fulfillments)
      end
    end
  end

  describe 'perform' do
    let(:storage_provider_name) { 'my_storage' }
    let(:csv_str) { 'foo' }
    let(:shipment) { Fulfillment::Shipment.new }

    shared_examples 'importer_perform' do
      it 'reads shipments' do
        params = {
          storage: storage_provider_name,
          complete_fulfillment: complete_fulfillment
        }
        storage_provider = double('storage_provider')
        Fulfillment::CSVStorageProvider.should_receive(:provider).with(storage_provider_name).and_return(storage_provider)
        storage_provider.should_receive(:read).with(params).and_return(csv_str)
        importer.should_receive(:to_shipments).with([[csv_str]]).and_return([shipment])
        importer.should_receive(:after_import).with([shipment], params)

        importer.perform(params)
      end
    end

    context 'complete_fulfillment is false' do
      let(:complete_fulfillment) { false }
      include_examples 'importer_perform'
    end

    context 'complete_fulfillment is true' do
      let(:complete_fulfillment) { true }
      before :each do
        shipment.should_receive(:complete!)
      end
      include_examples 'importer_perform'
    end
  end
end
