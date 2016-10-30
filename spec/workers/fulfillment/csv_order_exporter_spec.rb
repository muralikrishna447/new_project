require 'spec_helper'

describe Fulfillment::CSVOrderExporter do
  let(:exporter) { Class.new { include Fulfillment::CSVOrderExporter } }

  describe 'fulfillables' do
    let(:sku) { 'my sku' }
    let(:order_1_line_item_1) do
      line_item = ShopifyAPI::LineItem.new
      line_item.id = 11
      line_item.sku = order_1_line_item_1_sku
      line_item
    end
    let(:order_1_line_item_2) do
      line_item = ShopifyAPI::LineItem.new
      line_item.id = 12
      line_item.sku = order_1_line_item_2_sku
      line_item
    end
    let(:order_1) do
      order = ShopifyAPI::Order.new
      order.id = 1
      order.line_items = [order_1_line_item_1, order_1_line_item_2]
      order.fulfillments = order_1_fulfillments
      order
    end
    let(:order_2_line_item_1) do
      line_item = ShopifyAPI::LineItem.new
      line_item.id = 21
      line_item.sku = order_2_line_item_1_sku
      line_item
    end
    let(:order_2_line_item_2) do
      line_item = ShopifyAPI::LineItem.new
      line_item.id = 22
      line_item.sku = order_2_line_item_2_sku
      line_item
    end
    let(:order_2) do
      order = ShopifyAPI::Order.new
      order.id = 2
      order.line_items = [order_2_line_item_1, order_2_line_item_2]
      order.fulfillments = order_2_fulfillments
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

      context 'orders has line items with no fulfillments' do
        let(:order_1_fulfillments) { [] }
        let(:order_2_fulfillments) { [] }

        context 'sku matches on line items' do
          let(:order_1_line_item_1_sku) { sku }
          let(:order_1_line_item_2_sku) { sku }
          let(:order_2_line_item_1_sku) { sku }
          let(:order_2_line_item_2_sku) { sku }
          it 'creates fulfillables with all orders and line items' do
            expect(exporter.fulfillables(orders, [sku])).to match_array(
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
        end

        context 'sku matches on first line item only' do
          let(:another_sku) { 'another sku' }
          let(:order_1_line_item_1_sku) { sku }
          let(:order_1_line_item_2_sku) { another_sku }
          let(:order_2_line_item_1_sku) { sku }
          let(:order_2_line_item_2_sku) { another_sku }

          it 'creates fulfillable with all orders and first line item' do
            expect(exporter.fulfillables(orders, [sku])).to match_array(
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

        context 'sku does not match on any line items' do
          let(:another_sku) { 'another sku' }
          let(:order_1_line_item_1_sku) { another_sku }
          let(:order_1_line_item_2_sku) { another_sku }
          let(:order_2_line_item_1_sku) { another_sku }
          let(:order_2_line_item_2_sku) { another_sku }

          it 'creates empty fulfillables' do
            expect(exporter.fulfillables([], [sku])).to be_empty
          end
        end
      end

      context 'orders has line items with existing fulfillment' do
        let(:order_1_line_item_1_sku) { sku }
        let(:order_1_line_item_2_sku) { sku }
        let(:order_2_line_item_1_sku) { sku }
        let(:order_2_line_item_2_sku) { sku }

        let(:order_1_fulfillments) do
          fulfillment = ShopifyAPI::Fulfillment.new
          fulfillment.line_items = [order_1_line_item_1]
          fulfillment.status = order_1_line_item_1_status
          [fulfillment]
        end
        let(:order_2_fulfillments) do
          fulfillment = ShopifyAPI::Fulfillment.new
          fulfillment.line_items = [order_2_line_item_1]
          fulfillment.status = order_2_line_item_1_status
          [fulfillment]
        end

        context 'fulfillment has status open' do
          let(:order_1_line_item_1_status) { 'open' }
          let(:order_2_line_item_1_status) { 'open' }

          it 'creates fulfillables with line items that do not have open fulfillments' do
            expect(exporter.fulfillables(orders, [sku])).to match_array(
              [
                Fulfillment::Fulfillable.new(
                  order: order_1,
                  line_items: [order_1_line_item_2]
                ),
                Fulfillment::Fulfillable.new(
                  order: order_2,
                  line_items: [order_2_line_item_2]
                )
              ]
            )
          end
        end

        context 'fulfillment has status success' do
          let(:order_1_line_item_1_status) { 'open' }
          let(:order_2_line_item_1_status) { 'open' }

          it 'creates fulfillables with line items that do not have successful fulfillments' do
            expect(exporter.fulfillables(orders, [sku])).to match_array(
              [
                Fulfillment::Fulfillable.new(
                  order: order_1,
                  line_items: [order_1_line_item_2]
                ),
                Fulfillment::Fulfillable.new(
                  order: order_2,
                  line_items: [order_2_line_item_2]
                )
              ]
            )
          end
        end

        context 'fulfillment has status cancelled' do
          let(:order_1_line_item_1_status) { 'cancelled' }
          let(:order_2_line_item_1_status) { 'cancelled' }

          it 'creates fulfillables with all orders and line items' do
            expect(exporter.fulfillables(orders, [sku])).to match_array(
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
        end
      end
    end
  end

  describe 'include_order?' do
    let(:order) do
      order = ShopifyAPI::Order.new
      order.tags = tags
      order
    end

    context 'order has filtered tag' do
      shared_examples 'filtered tag' do
        it 'returns false' do
          Fulfillment::FedexShippingAddressValidator.should_not_receive(:valid?)
          expect(exporter.include_order?(order)).to be_false
        end
      end

      context 'order has shipping-started tag' do
        let(:tags) { 'shipping-started' }
        include_examples 'filtered tag'
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
          Fulfillment::FedexShippingAddressValidator.should_receive(:valid?).and_return(false)
          expect(exporter.include_order?(order)).to be_false
        end
      end

      context 'address validator returns true' do
        it 'returns true' do
          Fulfillment::FedexShippingAddressValidator.should_receive(:valid?).and_return(true)
          expect(exporter.include_order?(order)).to be_true
        end
      end
    end
  end

  describe 'sort!' do
    let(:fulfillable_1) do
      order = ShopifyAPI::Order.new
      order.processed_at = '2016-02-04T00:00:00-08:00'
      order.tags = order_1_tags
      Fulfillment::Fulfillable.new(order: order)
    end
    let(:fulfillable_2) do
      order = ShopifyAPI::Order.new
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
        expect(fulfillables).to match_array([fulfillable_1, fulfillable_2])
      end
    end

    context 'one order has priority tag' do
      let(:order_1_tags) { '' }
      let(:order_2_tags) { Fulfillment::CSVOrderExporter::PRIORITY_TAG }
      it 'bumps the order with the priority tag to the top' do
        exporter.sort!(fulfillables)
        expect(fulfillables).to match_array([fulfillable_2, fulfillable_1])
      end
    end

    context 'two orders have priority tag' do
      let(:order_1_tags) { Fulfillment::CSVOrderExporter::PRIORITY_TAG }
      let(:order_2_tags) { Fulfillment::CSVOrderExporter::PRIORITY_TAG }
      it 'sorts orders in order of processing time ascending' do
        exporter.sort!(fulfillables)
        expect(fulfillables).to match_array([fulfillable_1, fulfillable_2])
      end
    end
  end

  describe 'truncate' do
    let(:line_item_1) do
      line_item = ShopifyAPI::LineItem.new
      line_item.id = 1
      line_item.quantity = line_item_1_quantity
      line_item
    end
    let(:line_item_2) do
      line_item = ShopifyAPI::LineItem.new
      line_item.id = 2
      line_item.quantity = line_item_2_quantity
      line_item
    end
    let(:fulfillable_1) { Fulfillment::Fulfillable.new(line_items: [line_item_1]) }
    let(:fulfillable_2) { Fulfillment::Fulfillable.new(line_items: [line_item_2]) }
    let(:fulfillables) { [fulfillable_1, fulfillable_2] }

    context 'quantity requested is greater than total line item quantity' do
      let(:line_item_1_quantity) { 1 }
      let(:line_item_2_quantity) { 2 }

      it 'returns fulfillables with all line items' do
        expect(exporter.truncate(fulfillables, 100)).to match_array(fulfillables)
      end
    end

    context 'quantity requested is less than total line item quantity' do
      context 'line item has quantity that cannot be fulfilled with quantity requested' do
        let(:line_item_1_quantity) { 10 }
        let(:line_item_2_quantity) { 1 }

        it 'returns fulfillables with quantity less than requested' do
          expect(exporter.truncate(fulfillables, 9)).to match_array([fulfillable_2])
        end
      end

      context 'all line items have quantity of 1' do
        let(:line_item_1_quantity) { 1 }
        let(:line_item_2_quantity) { 1 }

        it 'returns fulfillables with quantity less than requested' do
          expect(exporter.truncate(fulfillables, 1)).to match_array([fulfillable_1])
        end
      end
    end
  end

  describe 'open_fulfillments' do
    let(:order_1_line_item) do
      line_item = ShopifyAPI::LineItem.new
      line_item.id = 11
      line_item
    end
    let(:order_1) do
      order = ShopifyAPI::Order.new
      order.id = 1
      order.line_items = [order_1_line_item]
      order
    end
    let(:order_2_line_item) do
      line_item = ShopifyAPI::LineItem.new
      line_item.id = 21
      line_item
    end
    let(:order_2) do
      order = ShopifyAPI::Order.new
      order.id = 2
      order.line_items = [order_2_line_item]
      order
    end
    let(:fulfillable_1) do
      Fulfillment::Fulfillable.new(
        order: order_1,
        line_items: [order_1_line_item]
      )
    end
    let(:fulfillable_2) do
      Fulfillment::Fulfillable.new(
        order: order_2,
        line_items: [order_2_line_item]
      )
    end
    let(:fulfillables) { [fulfillable_1, fulfillable_2] }

    it 'opens fulfillments for all fulfillable line items' do
      stub_open_fulfillment(order_1.id, order_1_line_item.id)
      stub_open_fulfillment(order_2.id, order_2_line_item.id)
      exporter.open_fulfillments(fulfillables)
    end
  end

  describe 'inner_perform' do
    shared_examples 'invalid params' do
      it 'raises exception' do
        expect { exporter.inner_perform(params) }.to raise_error
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
        line_item.quantity = 1
        line_item
      end
      let(:order) do
        order = ShopifyAPI::Order.new
        order.id = 1
        order.line_items = [line_item]
        order.fulfillments = []
        order.tags = ''
        order.processed_at = '2016-02-04T00:00:00-08:00'
        order
      end
      let(:storage_provider_name) { 'my storage' }
      let(:export_type) { 'my export type' }
      let(:csv_header) { 'my header' }
      let(:csv_body) { 'my order line items' }

      it 'saves open fulfillables to storage provider' do
        Shopify::Utils.should_receive(:search_orders).with(status: 'open').and_return([order])
        Fulfillment::FedexShippingAddressValidator.should_receive(:valid?).with(order).and_return(true)
        stub_open_fulfillment(order.id, line_item.id)

        exporter.should_receive(:schema).and_return([csv_header])
        exporter.should_receive(:type).and_return(export_type)
        exporter.should_receive(:transform).and_return([[csv_body]])

        storage_provider = double('storage_provider')
        storage_provider.should_receive(:save).with("\"#{csv_header}\"\n\"#{csv_body}\"\n", type: export_type)
        Fulfillment::CSVStorageProvider.should_receive(:provider).with(storage_provider_name).and_return(storage_provider)

        exporter.inner_perform(skus: [sku], quantity: 1, storage: storage_provider_name)
      end
    end
  end

  def stub_open_fulfillment(order_id, line_item_id)
    WebMock
      .stub_request(:post, /test.myshopify.com\/admin\/orders\/#{order_id}\/fulfillments.json/)
      .with(body: "{\"fulfillment\":{\"line_items\":[{\"id\":#{line_item_id}}],\"status\":\"open\",\"notify_customer\":false}}")
      .to_return(status: 200, body: '', headers: {})
  end
end
