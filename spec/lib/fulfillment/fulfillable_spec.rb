require 'spec_helper'

describe Fulfillment::Fulfillable do
  let(:line_item_1_quantity) { 1 }
  let(:line_item_1) do
    line_item = ShopifyAPI::LineItem.new
    line_item.id = 11
    line_item.fulfillable_quantity = line_item_1_quantity
    line_item
  end
  let(:line_item_2_quantity) { 2 }
  let(:line_item_2) do
    line_item = ShopifyAPI::LineItem.new
    line_item.id = 21
    line_item.fulfillable_quantity = line_item_2_quantity
    line_item
  end
  let(:order) do
    order = ShopifyAPI::Order.new
    order.id = 1
    order.line_items = [line_item_1, line_item_2]
    order.fulfillments = fulfillments
    order
  end
  let(:fulfillable) do
    Fulfillment::Fulfillable.new(
      order: order,
      line_items: [line_item_1, line_item_2]
    )
  end

  describe 'open_fulfillment' do
    context 'no open fulfillment exists' do
      let(:fulfillments) { [] }
      it 'opens fulfillment for line items' do
        stub_open_fulfillment(order.id, line_item_1.id, line_item_1.fulfillable_quantity)
        stub_open_fulfillment(order.id, line_item_2.id, line_item_2.fulfillable_quantity)
        Shopify::Utils
          .should_receive(:send_assert_true)
          .with(instance_of(ShopifyAPI::Fulfillment), :save)
          .exactly(2).times
        fulfillable.open_fulfillment
      end
    end

    context 'an open fulfillment exists' do
      let(:fulfillments) do
        [
          ShopifyAPI::Fulfillment.new(
            line_items: [{ id: line_item_1.id }],
            status: 'open'
          ),
          ShopifyAPI::Fulfillment.new(
            line_items: [{ id: line_item_2.id }],
            status: 'open'
          )
        ]
      end
      it 'does not open fulfillment for line items with open fulfillment' do
        Shopify::Utils.should_not_receive(:send_assert_true)
        fulfillable.open_fulfillment
      end
    end
  end

  describe 'quantity_for_line_item' do
    context 'no open fulfillment exists' do
      let(:fulfillments) { [] }
      it 'returns fulfillable quantity for line item' do
        expect(fulfillable.quantity_for_line_item(line_item_1)).to eq line_item_1.fulfillable_quantity
      end
    end

    context 'an open fulfillment exists' do
      let(:fulfillment_quantity) { 9 }
      let(:fulfillments) do
        [
          ShopifyAPI::Fulfillment.new(
            line_items: [{ id: line_item_1.id, quantity: fulfillment_quantity }],
            status: 'open'
          )
        ]
      end
      it 'returns quantity for open fulfillment' do
        expect(fulfillable.quantity_for_line_item(line_item_1)).to eq fulfillment_quantity
      end
    end
  end

  describe 'quantity' do
    let(:fulfillments) { [] }
    let(:total_quantity) { line_item_1_quantity + line_item_2_quantity }
    it 'returns sum of fulfillable quantity for all line items' do
      expect(fulfillable.quantity).to eq total_quantity
    end
  end

  def stub_open_fulfillment(order_id, line_item_id, qty)
    WebMock
      .stub_request(:post, /test.myshopify.com\/admin\/orders\/#{order_id}\/fulfillments.json/)
      .with(body: "{\"fulfillment\":{\"line_items\":[{\"id\":#{line_item_id},\"quantity\":#{qty}}],\"status\":\"open\",\"notify_customer\":false}}")
      .to_return(status: 200, body: '', headers: {})
  end
end
