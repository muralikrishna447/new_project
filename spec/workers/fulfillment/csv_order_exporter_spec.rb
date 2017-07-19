# encoding: UTF-8

require 'spec_helper'
require 'fulfillment/order_search_provider'

describe Fulfillment::CSVOrderExporter do
  let(:exporter) { Class.new { include Fulfillment::CSVOrderExporter } }

  describe 'fulfillables' do
    let(:sku) { 'my sku' }
    let(:fulfillable_quantity) { 1 }
    let(:order_1_line_item_1) { ShopifyAPI::LineItem.new(id: 11) }
    let(:order_1_line_item_2) { ShopifyAPI::LineItem.new(id: 12) }
    let(:order_1) do
      order = ShopifyAPI::Order.new
      order.id = 1
      order.line_items = [order_1_line_item_1, order_1_line_item_2]
      order
    end
    let(:order_2_line_item_1) { ShopifyAPI::LineItem.new(id: 21) }
    let(:order_2_line_item_2) { ShopifyAPI::LineItem.new(id: 22) }
    let(:order_2) do
      order = ShopifyAPI::Order.new
      order.id = 2
      order.line_items = [order_2_line_item_1, order_2_line_item_2]
      order
    end

    context 'orders is empty' do
      let(:orders) { [] }
      it 'creates empty fulfillables' do
        expect(exporter.fulfillables([], ['sku'])).to be_empty
      end
    end

    context 'orders is not empty' do
      let(:orders) { [order_1, order_2] }

      context 'no line items are fulfillable' do
        it 'creates empty fulfillables' do
          exporter.should_receive(:fulfillable_line_item?).exactly(4).times.and_return(false)
          expect(exporter.fulfillables(orders, [sku])).to be_empty
        end
      end

      context 'all line items are fulfillable' do
        it 'creates fulfillables with all orders and line items' do
          exporter.should_receive(:fulfillable_line_item?).exactly(4).times.and_return(true)
          expect(exporter.fulfillables(orders, [sku])).to eq(
            [
              Fulfillment::Fulfillable.new(
                order: order_1,
                line_items: [order_1_line_item_1, order_1_line_item_2]
              ),
              Fulfillment::Fulfillable.new(
                order: order_2,
                line_items: [order_2_line_item_1, order_2_line_item_2]
              )
            ]
          )
        end

        context 'only first line item is fulfillable' do
          it 'creates fulfillable with all orders and first line item' do
            exporter.should_receive(:fulfillable_line_item?).with(order_1, order_1_line_item_1, sku).and_return(true)
            exporter.should_receive(:fulfillable_line_item?).with(order_1, order_1_line_item_2, sku).and_return(false)
            exporter.should_receive(:fulfillable_line_item?).with(order_2, order_2_line_item_1, sku).and_return(true)
            exporter.should_receive(:fulfillable_line_item?).with(order_2, order_2_line_item_2, sku).and_return(false)
            expect(exporter.fulfillables(orders, [sku])).to eq(
              [
                Fulfillment::Fulfillable.new(
                  order: order_1,
                  line_items: [order_1_line_item_1]
                ),
                Fulfillment::Fulfillable.new(
                  order: order_2,
                  line_items: [order_2_line_item_1]
                )
              ]
            )
          end
        end

        context 'two skus are fulfillable' do
          let(:sku_2) { 'my_sku_2' }
          let(:order_1_line_item_1) { ShopifyAPI::LineItem.new(id: 11) }
          let(:order_1_line_item_2) { ShopifyAPI::LineItem.new(id: 12) }

          it 'creates fulfillable with order and two line items' do
            exporter
              .should_receive(:fulfillable_line_item?)
              .with(order_1, order_1_line_item_1, sku)
              .once.and_return(true)
            exporter
              .should_receive(:fulfillable_line_item?)
              .with(order_1, order_1_line_item_1, sku_2)
              .once.and_return(false)
            exporter
              .should_receive(:fulfillable_line_item?)
              .with(order_1, order_1_line_item_2, sku)
              .once.and_return(false)
            exporter
              .should_receive(:fulfillable_line_item?)
              .with(order_1, order_1_line_item_2, sku_2)
              .once.and_return(true)
            expect(exporter.fulfillables([order_1], [sku, sku_2])).to eq(
              [
                Fulfillment::Fulfillable.new(
                  order: order_1,
                  line_items: [order_1_line_item_1, order_1_line_item_2]
                )
              ]
            )
          end
        end
      end
    end
  end

  describe 'include_order?' do
    let(:tags) { '' }
    let(:financial_status) { 'paid' }
    let(:order) do
      ShopifyAPI::Order.new(
        tags: tags,
        financial_status: financial_status
      )
    end

    shared_examples 'payment status' do
      context 'order has not been paid' do
        let(:financial_status) { 'authorized' }
        it 'returns false' do
          expect(exporter.include_order?(order)).to be_false
        end
      end
      context 'order has been paid' do
        let(:financial_status) { 'paid' }
        it 'returns true' do
          expect(exporter.include_order?(order)).to be_true
        end
      end
    end

    context 'order has filtered tag' do
      shared_examples 'filtered tag' do
        it 'returns false' do
          Fulfillment::FedexShippingAddressValidator.should_not_receive(:valid?)
          expect(exporter.include_order?(order)).to be_false
        end
      end

      context 'order has shipping-hold tag' do
        let(:tags) { 'shipping-hold' }
        include_examples 'filtered tag'
      end

      context 'order has shipping-validation-error tag' do
        let(:tags) { 'shipping-validation-error' }
        include_examples 'filtered tag'
      end
    end

    context 'order has no filtered tags' do
      let(:tags) { 'other-tag' }

      context 'address validator returns false' do
        it 'returns false' do
          Fulfillment::FedexShippingAddressValidator.stub(:valid?).and_return(false)
          expect(exporter.include_order?(order)).to be_false
        end
      end

      context 'address validator returns true' do
        before :each do
          Fulfillment::FedexShippingAddressValidator.stub(:valid?).and_return(true)
        end

        it 'returns true' do
          expect(exporter.include_order?(order)).to be_true
        end
        include_examples 'payment status'
      end
    end
  end

  describe 'sort!' do
    let(:fulfillable_1) do
      order = ShopifyAPI::Order.new(id: 1)
      order.processed_at = '2016-02-04T00:00:00-08:00'
      order.tags = order_1_tags
      Fulfillment::Fulfillable.new(order: order)
    end
    let(:fulfillable_2) do
      order = ShopifyAPI::Order.new(id: 2)
      order.processed_at = '2016-02-05T00:00:00-08:00'
      order.tags = order_2_tags
      Fulfillment::Fulfillable.new(order: order)
    end
    # Fixture has orders in descending order of time placed
    let(:fulfillables) { [fulfillable_2, fulfillable_1] }

    context 'orders do not have priority tag' do
      let(:order_1_tags) { '' }
      let(:order_2_tags) { '' }
      it 'sorts orders in order of processing time ascending' do
        exporter.sort!(fulfillables)
        expect(fulfillables).to eq([fulfillable_1, fulfillable_2])
      end
    end

    context 'one order has priority tag' do
      let(:order_1_tags) { '' }
      let(:order_2_tags) { Fulfillment::CSVOrderExporter::PRIORITY_TAG }
      it 'bumps the order with the priority tag to the top' do
        exporter.sort!(fulfillables)
        expect(fulfillables).to eq([fulfillable_2, fulfillable_1])
      end
    end

    context 'two orders have priority tag' do
      let(:order_1_tags) { Fulfillment::CSVOrderExporter::PRIORITY_TAG }
      let(:order_2_tags) { Fulfillment::CSVOrderExporter::PRIORITY_TAG }
      it 'sorts orders in order of processing time ascending' do
        exporter.sort!(fulfillables)
        expect(fulfillables).to eq([fulfillable_1, fulfillable_2])
      end
    end
  end

  describe 'truncate' do
    let(:line_item_1) do
      line_item = ShopifyAPI::LineItem.new
      line_item.id = 1
      line_item.fulfillable_quantity = line_item_1_quantity
      line_item
    end
    let(:line_item_2) do
      line_item = ShopifyAPI::LineItem.new
      line_item.id = 2
      line_item.fulfillable_quantity = line_item_2_quantity
      line_item
    end
    let(:fulfillable_1) do
      Fulfillment::Fulfillable.new(
        order: ShopifyAPI::Order.new(id: 11),
        line_items: [line_item_1]
      )
    end
    let(:fulfillable_2) do
      Fulfillment::Fulfillable.new(
        order: ShopifyAPI::Order.new(id: 22),
        line_items: [line_item_2]
      )
    end
    let(:fulfillables) { [fulfillable_1, fulfillable_2] }

    context 'quantity requested is greater than total line item quantity' do
      let(:line_item_1_quantity) { 1 }
      let(:line_item_2_quantity) { 2 }

      it 'returns fulfillables with all line items' do
        expect(exporter.truncate(fulfillables, 100)).to eq(fulfillables)
      end
    end

    context 'quantity requested is less than total line item quantity' do
      context 'line item has quantity that cannot be fulfilled with quantity requested' do
        let(:line_item_1_quantity) { 10 }
        let(:line_item_2_quantity) { 1 }

        it 'returns fulfillables with quantity less than requested' do
          expect(exporter.truncate(fulfillables, 9)).to eq([fulfillable_2])
        end
      end

      context 'all line items have quantity of 1' do
        let(:line_item_1_quantity) { 1 }
        let(:line_item_2_quantity) { 1 }

        it 'returns fulfillables with quantity less than requested' do
          expect(exporter.truncate(fulfillables, 1)).to eq([fulfillable_1])
        end
      end
    end
  end

  describe 'perform' do
    shared_examples 'invalid params' do
      it 'raises exception' do
        expect { exporter.perform(params) }.to raise_error
      end
    end

    context 'skus param is not specfieid' do
      let(:params) { { quantity: 1, storage: 'my storage' } }
      include_examples 'invalid params'
    end

    context 'skus param is an empty array' do
      let(:params) { { quantity: 1, skus: [], storage: 'my storage' } }
      include_examples 'invalid params'
    end

    context 'quantity param is not specified' do
      let(:params) { { skus: ['my sku'], storage: 'my storage' } }
      include_examples 'invalid params'
    end

    context 'quantity param is 0' do
      let(:params) { { quantity: 0, skus: ['my sku'], storage: 'my storage' } }
      include_examples 'invalid params'
    end

    context 'storage param is not specified' do
      let(:params) { { quantity: 1, skus: ['my sku'] } }
      include_examples 'invalid params'
    end

    context 'params are valid' do
      let(:sku) { 'my sku' }
      let(:line_item) do
        line_item = ShopifyAPI::LineItem.new
        line_item.id = 11
        line_item.sku = sku
        line_item.fulfillable_quantity = 1
        line_item
      end
      let(:order) do
        order = ShopifyAPI::Order.new(
            shipping_address: {
                address1: 'Hällo'
            }
        )
        order.id = 1
        order.line_items = [line_item]
        order.fulfillments = []
        order.tags = ''
        order.processed_at = '2016-02-04T00:00:00-08:00'
        order.financial_status = 'paid'
        order
      end
      let(:storage_provider_name) { 'my storage' }
      let(:export_type) { 'my export type' }
      let(:csv_header) { 'my header' }
      let(:csv_body) { 'my order line items' }

      it 'saves fulfillables' do
        Fulfillment::FedexShippingAddressValidator.should_receive(:valid?).with(order).and_return(true)
        Fulfillment::OrderCleaners.should_receive(:clean!).with(order).and_call_original

        exporter.should_receive(:schema).and_return([csv_header])
        exporter.should_receive(:type).and_return(export_type)
        exporter.should_receive(:transform){|ff|
          # Check that the cleaner worked
          expect(ff.order.shipping_address.address1).to eq('Hallo')
        }.and_return([[csv_body]])
        exporter.should_receive(:fulfillable_line_item?).and_return(true)
        exporter.should_receive(:orders).and_return([order])
        exporter.should_receive(:before_save)
        exporter.should_receive(:after_save)

        storage_provider = double('storage_provider')
        params = {
          skus: [sku],
          quantity: 1,
          storage: storage_provider_name
        }
        storage_provider.should_receive(:save).with("\"#{csv_header}\"\n\"#{csv_body}\"\n", params.merge(type: export_type))
        Fulfillment::CSVStorageProvider.should_receive(:provider).with(storage_provider_name).and_return(storage_provider)

        exporter.perform(params)
      end
    end
  end
end
