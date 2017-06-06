require 'spec_helper'

describe Fulfillment::FbaOrderSubmitter do
  describe 'after_save' do
    let(:quantity) { 2 }
    let(:line_item) do
      ShopifyAPI::LineItem.new(
        id: 'my-line-item',
        sku: sku,
        fulfillable_quantity: quantity
      )
    end
    let(:fulfillable) do
      Fulfillment::Fulfillable.new(
        order: ShopifyAPI::Order.new(
          id: 'my-order-id',
          line_items: [line_item]
        ),
        line_items: [line_item]
      )
    end
    let(:fulfillables) { [fulfillable] }

    context 'SKU is fulfillable by FBA' do
      let(:sku) { 'cs30001' }
      let(:seller_fulfillment_order_id) { 'my-order-id' }

      before :each do
        Fulfillment::Fba
          .stub(:seller_fulfillment_order_id)
          .and_return(seller_fulfillment_order_id)
      end

      context 'FBA fulfillment order exists' do
        before do
          Fulfillment::Fba
            .stub(:fulfillment_order)
            .with(seller_fulfillment_order_id)
            .and_return('FulfillmentOrder' => { 'ReceivedDateTime' => 'submitted-time' })
        end

        it 'does not create FBA fulfillment order' do
          Fulfillment::Fba.should_not_receive(:create_fulfillment_order)
          Fulfillment::FbaOrderSubmitter.should_receive(:report_metrics).with(0, 0)
          Fulfillment::FbaOrderSubmitter.after_save(fulfillables, {})
        end
      end

      context 'FBA fulfillment order does not exist' do
        before do
          Fulfillment::Fba
            .stub(:fulfillment_order)
            .with(seller_fulfillment_order_id)
            .and_return(nil)
        end

        context 'create_fulfillment_order param is truthy' do
          it 'creates FBA fulfillment order' do
            Fulfillment::Fba
              .should_receive(:create_fulfillment_order)
              .with(fulfillable, line_item)
            Fulfillment::FbaOrderSubmitter.should_receive(:report_metrics).with(1, quantity)
            Fulfillment::FbaOrderSubmitter.after_save(fulfillables, create_fulfillment_orders: true)
          end
        end

        context 'create_fulfillment_order param is falsey' do
          it 'does not create FBA fulfillment order' do
            Fulfillment::Fba.should_not_receive(:create_fulfillment_order)
            Fulfillment::FbaOrderSubmitter.should_receive(:report_metrics).with(0, 0)
            Fulfillment::FbaOrderSubmitter.after_save(fulfillables, create_fulfillment_orders: false)
          end
        end
      end
    end

    context 'SKU is not fulfillable by FBA' do
      let(:sku) { 'other-sku' }
      it 'raises error' do
        expect { Fulfillment::FbaOrderSubmitter.after_save(fulfillables, {}) }.to raise_error
      end
    end
  end
end
