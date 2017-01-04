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

  describe 'complete_shipment' do
    let(:order_id) { 1 }
    let(:fulfillment_1) do
      fulfillment = ShopifyAPI::Fulfillment.new(id: 1)
      fulfillment.prefix_options[:order_id] = order_id
      fulfillment.attributes[:tracking_company] = fulfillment_1_tracking_company
      fulfillment.attributes[:tracking_numbers] = fulfillment_1_tracking_numbers
      fulfillment
    end
    let(:fulfillment_2) do
      fulfillment = ShopifyAPI::Fulfillment.new(id: 2)
      fulfillment.prefix_options[:order_id] = order_id
      fulfillment.attributes[:tracking_company] = fulfillment_2_tracking_company
      fulfillment.attributes[:tracking_numbers] = fulfillment_2_tracking_numbers
      fulfillment
    end
    let(:tracking_company) { 'my tracking company' }
    let(:tracking_numbers) { ['123', '456'] }
    let(:shipment) do
      Fulfillment::Shipment.new(
        order: ShopifyAPI::Order.new(id: order_id, name: '#myordername'),
        fulfillments: [fulfillment_1, fulfillment_2],
        tracking_company: tracking_company,
        tracking_numbers: tracking_numbers
      )
    end

    context 'tracking has been updated' do
      let(:fulfillment_1_tracking_company) { tracking_company }
      let(:fulfillment_1_tracking_numbers) { tracking_numbers }
      let(:fulfillment_2_tracking_company) { tracking_company }
      let(:fulfillment_2_tracking_numbers) { tracking_numbers }

      it 'does not update tracking and completes all fulfillments' do
        stub_fulfillment_complete(order_id, fulfillment_1.id)
        stub_fulfillment_complete(order_id, fulfillment_2.id)
        Shopify::Utils
          .should_receive(:send_assert_true)
          .with(instance_of(ShopifyAPI::Fulfillment), :save)
          .twice
        Shopify::Utils
          .should_receive(:send_assert_true)
          .with(instance_of(ShopifyAPI::Fulfillment), :complete)
          .twice

        importer.complete_shipment(shipment)
      end
    end

    context 'tracking has not been updated' do
      let(:fulfillment_1_tracking_company) { nil }
      let(:fulfillment_1_tracking_numbers) { [] }
      let(:fulfillment_2_tracking_company) { nil }
      let(:fulfillment_2_tracking_numbers) { [] }

      it 'updates tracking and completes all fulfillments' do
        stub_fulfillment_update(order_id, fulfillment_1.id, tracking_company, tracking_numbers, false)
        stub_fulfillment_update(order_id, fulfillment_1.id, tracking_company, tracking_numbers, true)
        stub_fulfillment_complete(order_id, fulfillment_1.id)

        stub_fulfillment_update(order_id, fulfillment_2.id, tracking_company, tracking_numbers, false)
        stub_fulfillment_update(order_id, fulfillment_2.id, tracking_company, tracking_numbers, true)
        stub_fulfillment_complete(order_id, fulfillment_2.id)

        Shopify::Utils
          .should_receive(:send_assert_true)
          .with(instance_of(ShopifyAPI::Fulfillment), :save)
          .exactly(4).times
        Shopify::Utils
          .should_receive(:send_assert_true)
          .with(instance_of(ShopifyAPI::Fulfillment), :complete)
          .twice

        importer.complete_shipment(shipment)
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
        importer.should_receive(:complete_shipment).with(shipment)
      end
      include_examples 'importer_perform'
    end
  end

  def stub_fulfillment_update(order_id, fulfillment_id, tracking_company, tracking_numbers, notify_customer)
    WebMock
      .stub_request(:put, /test.myshopify.com\/admin\/orders\/#{order_id}\/fulfillments\/#{fulfillment_id}.json/)
      .with(body: "{\"fulfillment\":{\"id\":#{fulfillment_id},\"tracking_company\":\"my tracking company\",\"tracking_numbers\":#{tracking_numbers.to_json},\"notify_customer\":#{notify_customer}}}")
      .to_return(status: 200, body: '')
  end

  def stub_fulfillment_complete(order_id, fulfillment_id)
    WebMock
      .stub_request(:post, /test.myshopify.com\/admin\/orders\/#{order_id}\/fulfillments\/#{fulfillment_id}\/complete.json/)
      .with(body: '{}')
      .to_return(status: 200, body: '')
  end
end
