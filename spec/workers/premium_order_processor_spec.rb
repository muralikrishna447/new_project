require 'spec_helper'

describe PremiumOrderProcessor do
  describe 'perform' do
    let(:order_id) { 1234 }
    let(:order) do
      ShopifyAPI::Order.new(
        id: order_id,
        line_items: line_items
      )
    end
    let(:order_wrapper) { 'order_wrapper' }
    before :each do
      Shopify::Utils.stub(:order_by_id).with(order_id).and_return(order)
      Shopify::Order.stub(:new).with(order).and_return(order_wrapper)
    end

    context 'order has premium line item' do
      let(:premium_line_item) { ShopifyAPI::LineItem.new(sku: Shopify::Order::PREMIUM_SKU) }
      let(:line_items) { [premium_line_item] }

      context 'order contains only premium line item' do
        it 'calls capture_only_premium and fulfill_premium_items' do
          PremiumOrderProcessor.should_receive(:capture_only_premium).with(order_wrapper, order)
          PremiumOrderProcessor.should_receive(:fulfill_premium_items).with(order_wrapper, order, line_items)
          PremiumOrderProcessor.perform(order_id)
        end
      end

      context 'order has additional line items' do
        let(:other_line_item) { ShopifyAPI::LineItem.new(sku: Shopify::Order::JOULE_SKU) }
        let(:line_items) { [premium_line_item, other_line_item] }

        it 'calls fulfill_premium_items and does not call capture_only_premium' do
          PremiumOrderProcessor.should_not_receive(:capture_only_premium)
          PremiumOrderProcessor.should_receive(:fulfill_premium_items).with(order_wrapper, order, [premium_line_item])
          PremiumOrderProcessor.perform(order_id)
        end
      end
    end

    context 'order does not have premium line item' do
      let(:line_items) { [] }
      it 'does not call capture_only_premium nor fulfill_premium' do
        PremiumOrderProcessor.should_not_receive(:capture_only_premium)
        PremiumOrderProcessor.should_not_receive(:fulfill_premium_items)
        PremiumOrderProcessor.perform(order_id)
      end
    end
  end

  describe 'capture_only_premium' do
    let(:order) { ShopifyAPI::Order.new(id: 1234) }
    let(:order_wrapper) { double('order_wrapper') }

    context 'order is capturable' do
      before :each do
        PremiumOrderProcessor.stub(:capturable?).and_return(true)
      end
      it 'calls capture_payment and sends analytics' do
        PremiumOrderProcessor.should_receive(:capture_payment).with(order)
        order_wrapper.should_receive(:send_analytics)
        PremiumOrderProcessor.capture_only_premium(order_wrapper, order)
      end
    end

    context 'order is not capturable' do
      before :each do
        PremiumOrderProcessor.stub(:capturable?).and_return(false)
      end
      it 'does not call capture_payment' do
        PremiumOrderProcessor.should_not_receive(:capture_payment)
        PremiumOrderProcessor.capture_only_premium(order_wrapper, order)
      end
    end
  end

  describe 'fulfill_premium_items' do
    let(:premium_line_item) { ShopifyAPI::LineItem.new(sku: Shopify::Order::PREMIUM_SKU) }
    let(:order) do
      ShopifyAPI::Order.new(
        id: 1234,
        line_items: [premium_line_item]
      )
    end
    let(:order_wrapper) { double('order_wrapper') }

    before :each do
      PremiumOrderProcessor
        .should_receive(:fulfill_premium_item)
        .with(order_wrapper, order, premium_line_item)
        .and_return(was_fulfilled)
    end

    context 'a premium line item was fulfilled' do
      let(:was_fulfilled) { true }
      it 'syncs user' do
        order_wrapper.should_receive(:sync_user)
        PremiumOrderProcessor.fulfill_premium_items(order_wrapper, order, [premium_line_item])
      end
    end

    context 'a premium line item was not fulfilled' do
      let(:was_fulfilled) { false }
      it 'does not sync user' do
        order_wrapper.should_not_receive(:sync_user)
        PremiumOrderProcessor.fulfill_premium_items(order_wrapper, order, [premium_line_item])
      end
    end
  end

  describe 'fulfill_premium_item' do
    let(:order_wrapper) { double('order_wrapper') }
    let(:order) do
      ShopifyAPI::Order.new(
        id: 1234,
        line_items: [line_item],
        created_at: '2017-02-21T14:38:33-08:00'
      )
    end
    let(:line_item) do
      ShopifyAPI::LineItem.new(sku: Shopify::Order::PREMIUM_SKU, quantity: quantity)
    end

    context 'fulfillable_line_item? returns false' do
      let(:quantity) { 1 }
      before :each do
        PremiumOrderProcessor.stub(:fulfillable_line_item?).with(line_item).and_return(false)
      end

      it 'does not fulfill premium and returns false' do
        order_wrapper.should_not_receive(:fulfill_premium)
        expect(PremiumOrderProcessor.fulfill_premium_item(order_wrapper, order, line_item)).to be_false
      end
    end

    context 'fulfillable_line_item? returns true' do
      before :each do
        PremiumOrderProcessor.stub(:fulfillable_line_item?).with(line_item).and_return(true)
      end

      context 'order is not a gift' do
        before :each do
          order_wrapper.stub(:gift_order?).and_return(false)
        end

        context 'order has premium line item with quantity 1' do
          let(:quantity) { 1 }
          it 'calls fulfill_premium and returns true' do
            order_wrapper.should_receive(:fulfill_premium).with(line_item, true)
            expect(PremiumOrderProcessor.fulfill_premium_item(order_wrapper, order, line_item)).to be_true
          end
        end

        context 'order has premium line item with quantity > 1' do
          let(:quantity) { 2 }
          it 'raises exception' do
            expect { PremiumOrderProcessor.fulfill_premium_item(order_wrapper, order, line_item) }.to raise_error
          end
        end
      end

      context 'order is a gift' do
        let(:quantity) { 1 }
        before :each do
          order_wrapper.stub(:gift_order?).and_return(true)
        end

        it 'calls fulfill_premium and returns true' do
          order_wrapper.should_receive(:fulfill_premium).with(line_item, true)
          expect(PremiumOrderProcessor.fulfill_premium_item(order_wrapper, order, line_item)).to be_true
        end
      end
    end
  end

  describe 'fulfillable_line_item?' do
    let(:line_item) do
      ShopifyAPI::LineItem.new(
        fulfillment_status: fulfillment_status,
        fulfillable_quantity: fulfillable_quantity
      )
    end

    context 'fulfillment_status is fulfilled' do
      let(:fulfillment_status) { 'fulfilled' }
      let(:fulfillable_quantity){ 0 }
      it 'returns false' do
        expect(PremiumOrderProcessor::fulfillable_line_item?(line_item)).to be_false
      end
    end

    context 'fulfillment status is not fulfilled' do
      let(:fulfillment_status) { nil }
      context 'fulfillable quantity is zero' do
        let (:fulfillable_quantity) { 0 }
        it 'returns false' do
          expect(PremiumOrderProcessor::fulfillable_line_item?(line_item)).to be_false
        end
      end

      context 'fulfillable_quantity is greater than zero' do
        let(:fulfillable_quantity) { 1 }
        it 'returns true' do
          expect(PremiumOrderProcessor::fulfillable_line_item?(line_item)).to be_true
        end
      end
    end
  end
end
