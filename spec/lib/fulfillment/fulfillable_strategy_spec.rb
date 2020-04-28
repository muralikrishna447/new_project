require 'spec_helper'

describe Fulfillment::FulfillableStrategy do
  describe Fulfillment::FulfillableStrategy::Export do
    let(:exporter) { Class.new { include Fulfillment::FulfillableStrategy::Export } }

    describe 'fulfillable_line_item?' do
      let(:sku) { 'my sku' }
      let(:fulfillable_quantity) { 1 }
      let(:line_item) do
        line_item = ShopifyAPI::LineItem.new
        line_item.id = 11
        line_item.sku = line_item_sku
        line_item.fulfillable_quantity = fulfillable_quantity
        line_item
      end
      let(:order) do
        order = ShopifyAPI::Order.new
        order.id = 1
        order.line_items = [line_item]
        order.fulfillments = fulfillments
        order
      end

      context 'order has line items with no fulfillment' do
        let(:fulfillments) { [] }

        context 'sku matches on line item' do
          let(:line_item_sku) { sku }
          it 'returns true' do
            expect(exporter.fulfillable_line_item?(order, line_item, sku)).to be true
          end

          context 'fulfillable quantity is zero' do
            let(:fulfillable_quantity) { 0 }

            it 'returns false' do
              expect(exporter.fulfillable_line_item?(order, line_item, sku)).to be false
            end
          end
        end

        context 'sku does not match on line item' do
          let(:line_item_sku) { 'another sku' }

          it 'returns false' do
            expect(exporter.fulfillable_line_item?(order, line_item, sku)).to be false
          end
        end
      end

      context 'orders has line items with existing fulfillment' do
        let(:line_item_sku) { sku }

        let(:fulfillments) do
          fulfillment = ShopifyAPI::Fulfillment.new
          fulfillment.line_items = [line_item]
          fulfillment.status = fulfillment_status
          [fulfillment]
        end

        context 'fulfillment has status open' do
          let(:fulfillment_status) { 'open' }

          it 'returns false' do
            expect(exporter.fulfillable_line_item?(order, line_item, sku)).to be false
          end
        end

        context 'fulfillment has status success' do
          let(:fulfillment_status) { 'success' }

          it 'returns false' do
            expect(exporter.fulfillable_line_item?(order, line_item, sku)).to be false
          end
        end

        context 'fulfillment has status cancelled' do
          let(:fulfillment_status) { 'cancelled' }

          it 'returns true' do
            expect(exporter.fulfillable_line_item?(order, line_item, sku)).to be true
          end
        end
      end

      describe 'after_save' do
        let(:line_item_sku) { sku }
        let(:fulfillments) { [] }
        let(:fulfillables) { [Fulfillment::Fulfillable.new(order: order, line_items: [line_item])] }
        context 'trigger_child_job param is true' do
          let(:child_job_class) { 'Class' }
          let(:child_job_params) { { foo: 'bar' } }

          it 'queues child job' do
            child_job_class.constantize.should_receive(:perform).with(child_job_params)
            exporter.after_save(
              fulfillables,
              trigger_child_job: true,
              child_job_class: child_job_class,
              child_job_params: child_job_params
            )
          end
        end

        context 'trigger_child_job param is false' do
          it 'does not queue child job' do
            exporter.should_not_receive(:perform)
            exporter.after_save(fulfillables, trigger_child_job: false)
          end
        end
      end
    end
  end

  describe Fulfillment::FulfillableStrategy::OpenFulfillment do
    let(:exporter) { Class.new { include Fulfillment::FulfillableStrategy::OpenFulfillment } }

    describe 'fulfillable_line_item?' do
      let(:sku) { 'my sku' }
      let(:line_item_sku) { sku }
      let(:fulfillable_quantity) { 1 }
      let(:order_cancelled_at) { nil }
      let(:line_item) do
        line_item = ShopifyAPI::LineItem.new
        line_item.id = 11
        line_item.sku = line_item_sku
        line_item.fulfillable_quantity = fulfillable_quantity
        line_item
      end
      let(:order) do
        order = ShopifyAPI::Order.new
        order.id = 1
        order.line_items = [line_item]
        order.fulfillments = fulfillments
        order.cancelled_at = order_cancelled_at
        order
      end

      context 'line item has no fulfillments' do
        let(:fulfillments) { [] }

        context 'line item is nil' do
          it 'returns false' do
            expect(exporter.fulfillable_line_item?(order, nil, sku)).to be false
          end
        end

        context 'line item sku does not match' do
          let(:line_item_sku) { 'another sku' }
          it 'returns false' do
            expect(exporter.fulfillable_line_item?(order, line_item, sku)).to be false
          end
        end

        context 'order is cancelled' do
          let(:order_cancelled_at) { Time.now.utc.iso8601 }
          it 'returns false' do
            expect(exporter.fulfillable_line_item?(order, line_item, sku)).to be false
          end
        end

        context 'line item sku matches' do
          it 'returns true' do
            expect(exporter.fulfillable_line_item?(order, line_item, sku)).to be true
          end
        end
      end

      context 'line item has successful fulfillment' do
        let(:fulfillments) do
          [
            ShopifyAPI::Fulfillment.new(
              line_items: [line_item],
              status: 'success'
            )
          ]
        end
        it 'returns false' do
          expect(exporter.fulfillable_line_item?(order, line_item, sku)).to be false
        end
      end

      context 'line item has open fulfillment' do
        let(:fulfillments) do
          [
            ShopifyAPI::Fulfillment.new(
              line_items: [line_item],
              status: 'open'
            )
          ]
        end
        it 'returns true' do
          expect(exporter.fulfillable_line_item?(order, line_item, sku)).to be true
        end
      end
    end

    describe 'before_save' do
      let(:fulfillable_1) do
        Fulfillment::Fulfillable.new(
          order: ShopifyAPI::Order.new(id: 1),
          line_items: ShopifyAPI::LineItem.new(id: 11)
        )
      end
      let(:fulfillable_2) do
        Fulfillment::Fulfillable.new(
          order: ShopifyAPI::Order.new(id: 2),
          line_items: ShopifyAPI::LineItem.new(id: 21)
        )
      end
      let(:fulfillables) { [fulfillable_1, fulfillable_2] }

      context 'open_fulfillment param is true' do
        it 'calls open_fulfillment on each fulfillable' do
          fulfillable_1.should_receive(:open_fulfillment)
          fulfillable_2.should_receive(:open_fulfillment)
          exporter.before_save(fulfillables, open_fulfillment: true)
        end
      end

      context 'open_fulfillment param is false' do
        it 'does not call open_fulfillment on fulfillable' do
          fulfillable_1.should_not_receive(:open_fulfillment)
          fulfillable_2.should_not_receive(:open_fulfillment)
          exporter.before_save(fulfillables, open_fulfillment: false)
        end
      end
    end
  end
end
