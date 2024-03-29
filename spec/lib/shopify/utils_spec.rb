require 'spec_helper'

describe Shopify::Utils, :skip => 'true' do
  describe 'order_tags' do
    context 'order tags is empty' do
      let(:order) do
        order = double('order')
        order.stub(:tags) { '' }
        order
      end

      it 'returns an empty array' do
        expect(Shopify::Utils.order_tags(order)).to be_empty
      end
    end

    context 'order tags is non-empty' do
      let(:tag_1) { 'my tag 1' }
      let(:tag_2) { 'my tag 2' }
      let(:order) do
        order = double('order')
        order.stub(:tags) { "#{tag_1}, #{tag_2}" }
        order
      end

      it 'returns the array of tags' do
        expect(Shopify::Utils.order_tags(order)).to eq([tag_1, tag_2])
      end
    end
  end

  describe 'add_to_order_tags' do
    context 'other tags exist on order' do
      let(:tag_1) { 'my tag 1' }
      let(:tag_2) { 'my tag 2' }
      let(:tag_3) { 'my tag 3' }
      let(:order) do
        order = double('order')
        order.stub(:tags) { tag_1 }
        order.stub(:tags=)
        order
      end

      it 'adds new tags and preserves existing tags' do
        order.should_receive(:tags=).with("#{tag_1},#{tag_2},#{tag_3}")
        updated = Shopify::Utils.add_to_order_tags(order, [tag_2, tag_3])
        expect(updated).to be_true
      end
    end

    context 'same tags exist on order' do
      let(:tag_1) { 'my tag 1' }
      let(:order) do
        order = double('order')
        order.stub(:tags) { tag_1 }
        order.stub(:tags=)
        order
      end

      it 'does not update tags' do
        order.should_not_receive(:tags=)
        updated = Shopify::Utils.add_to_order_tags(order, [tag_1])
        expect(updated).to be_false
      end
    end

    context 'no tags exist on order' do
      let(:order) do
        order = double('order')
        order.stub(:tags) { '' }
        order.stub(:tags=)
        order
      end

      it 'does not update tags when adding empty list of tags' do
        order.should_not_receive(:tags=)
        updated = Shopify::Utils.add_to_order_tags(order, [])
        expect(updated).to be_false
      end

      it 'updates tags when adding non-empty list of tags' do
        tag = 'my tag'
        order.should_receive(:tags=).with(tag)
        updated = Shopify::Utils.add_to_order_tags(order, [tag])
        expect(updated).to be_true
      end
    end
  end

  describe 'remove_from_order_tags' do
    context 'no matching tags exist on order' do
      let(:tags) { 'A,B,C' }
      let(:order) do
        order = double('order')
        order.stub(:tags) { tags }
        order.stub(:tags=)
        order
      end

      it 'sets order tags to same' do
        order.should_receive(:tags=).with(tags)
        Shopify::Utils.remove_from_order_tags(order, ['D'])
      end
    end

    context 'matching tags exist on order' do
      let(:tags) { 'A,B,C,D' }
      let(:order) do
        order = double('order')
        order.stub(:tags) { tags }
        order.stub(:tags=)
        order
      end

      it 'removes tags from order' do
        order.should_receive(:tags=).with('B,D')
        Shopify::Utils.remove_from_order_tags(order, ['A', 'C'])
      end
    end
  end

  describe 'order_by_name' do
    context 'order name is empty' do
      it 'raises exception' do
        expect { Shopify::Utils.order_by_name('') }.to raise_error
      end
    end

    context 'order name is not empty' do
      let(:order_name) { 'my_order_name' }

      before :each do
        Shopify::Utils.should_receive(:search_orders).with(
          name: order_name,
          status: 'any'
        ).and_return(orders)
      end

      context 'no orders are found' do
        let(:orders) { [] }
        it 'returns nil' do
          expect(Shopify::Utils.order_by_name(order_name)).to be_nil
        end
      end

      context 'one order is found' do
        let(:order) { ShopifyAPI::Order.new(id: 1) }
        let(:orders) { [order] }
        it 'returns the order' do
          expect(Shopify::Utils.order_by_name(order_name)).to eq order
        end
      end

      context 'more than one order is found' do
        let(:orders) do
          [
            ShopifyAPI::Order.new(id: 1),
            ShopifyAPI::Order.new(id: 2)
          ]
        end
        it 'raises exception' do
          expect { Shopify::Utils.order_by_name(order_name) }.to raise_error
        end
      end
    end
  end

  describe 'search_orders' do
    let(:page_size) { 2 }
    let(:order_1) { ShopifyAPI::Order.new(id: 1) }
    let(:order_2) { ShopifyAPI::Order.new(id: 2) }
    let(:order_3) { ShopifyAPI::Order.new(id: 3) }
    let(:param_key) { 'my_key'.to_sym }
    let(:param_value) { 'my_value' }
    let(:params) { { my_key: 'my_value' } }

    it 'returns all orders' do
      Shopify::Utils
        .stub(:search_orders_with_each)
        .with(params, page_size)
        .and_yield(order_1).and_yield(order_2).and_yield(order_3)
      expect(Shopify::Utils.search_orders(params, page_size)).to eq [order_1, order_2, order_3]
    end
  end

  describe 'search_orders_with_each' do
    let(:page_size) { 2 }
    let(:order_1) { ShopifyAPI::Order.new(id: 1) }
    let(:order_2) { ShopifyAPI::Order.new(id: 2) }
    let(:order_3) { ShopifyAPI::Order.new(id: 3) }
    let(:param_key) { 'my_key'.to_sym }
    let(:param_value) { 'my_value' }

    context 'response has order count equal to page size' do
      it 'yields results from all pages' do
        path_1 = ShopifyAPI::Order.collection_path(limit: page_size, page: 1, param_key => param_value)
        ShopifyAPI::Order.should_receive(:find).once.with(:all, from: path_1).and_return([order_1, order_2])
        path_2 = ShopifyAPI::Order.collection_path(limit: page_size, page: 2, param_key => param_value)
        ShopifyAPI::Order.should_receive(:find).once.with(:all, from: path_2).and_return([order_3])

        orders = []
        Shopify::Utils.search_orders_with_each({ param_key => param_value }, page_size) do |order|
          orders << order
        end
        expect(orders).to eq [order_1, order_2, order_3]
      end
    end

    context 'response has order count less than page size' do
      it 'does not request another page' do
        path_1 = ShopifyAPI::Order.collection_path(limit: page_size, page: 1, param_key => param_value)
        ShopifyAPI::Order.should_receive(:find).once.with(:all, from: path_1).and_return([order_1])

        orders = []
        Shopify::Utils.search_orders_with_each({ param_key => param_value }, page_size) do |order|
          orders << order
        end
        expect(orders).to eq [order_1]
      end
    end
  end

  describe 'send_assert_true' do
    let(:method_symbol) { :foo }
    let(:obj) { double('obj') }

    before :each do
      obj.should_receive(method_symbol).and_return(return_value)
    end

    context 'method returns true' do
      let(:return_value) { true }
      it 'does not raise error' do
        Shopify::Utils.send_assert_true(obj, method_symbol)
      end
    end

    context 'method returns false' do
      let(:return_value) { false }
      it 'raises error' do
        expect { Shopify::Utils.send_assert_true(obj, method_symbol) }.to raise_error
      end
    end
  end

  describe 'order_by_id' do
    let(:order_id) { 1234 }
    let(:order) { ShopifyAPI::Order.new(id: order_id) }

    context 'order exists' do
      before :each do
        ShopifyAPI::Order.stub(:find).with(order_id).and_return(order)
      end
      it 'returns order' do
        expect(Shopify::Utils.order_by_id(order_id)).to eq order
      end
    end

    context 'order does not exist' do
      before :each do
        ShopifyAPI::Order
          .stub(:find)
          .with(order_id)
          .and_raise(ActiveResource::ResourceNotFound.new(double('response')))
      end
      it 'raises error' do
        expect{ Shopify::Utils.order_by_id(order_id) }.to raise_error
      end
    end
  end

  describe 'contains_only_premium?' do
    let(:order) { ShopifyAPI::Order.new(line_items: line_items) }
    context 'order line items contain only premium' do
      let(:line_items) do
        [
          ShopifyAPI::LineItem.new(sku: Shopify::Order::PREMIUM_SKU)
        ]
      end
      it 'returns true' do
        expect(Shopify::Utils.contains_only_premium?(order)).to be_true
      end
    end

    context 'order line items has something other than premium' do
      let(:line_items) do
        [
          ShopifyAPI::LineItem.new(sku: Shopify::Order::PREMIUM_SKU),
          ShopifyAPI::LineItem.new(sku: Shopify::Order::JOULE_SKU)
        ]
      end
      it 'returns false' do
        expect(Shopify::Utils.contains_only_premium?(order)).to be_false
      end
    end
  end

  describe 'line_items_for_skus' do
    let(:order) { ShopifyAPI::Order.new(id: 1, line_items: line_items) }
    let(:sku_1) { 'sku_1' }
    let(:sku_2) { 'sku_2' }
    let(:sku_3) { 'sku_3' }
    let(:line_item_1) { ShopifyAPI::LineItem.new(sku: sku_1) }
    let(:line_item_2) { ShopifyAPI::LineItem.new(sku: sku_2) }
    let(:line_item_3) { ShopifyAPI::LineItem.new(sku: sku_3) }

    context 'order has line items matching skus' do
      let(:line_items) { [line_item_1, line_item_2, line_item_3] }
      let(:skus) { [sku_1, sku_3] }
      it 'returns an array of line items matching skus' do
        expect(Shopify::Utils.line_items_for_skus(order, skus)).to eq [
          line_item_1,
          line_item_3
        ]
      end
    end

    context 'order has no line items matching skus' do
      let(:line_items) { [line_item_3] }
      let(:skus) { [sku_1, sku_2] }
      it 'returns an empty array' do
        expect(Shopify::Utils.line_items_for_skus(order, skus)).to be_empty
      end
    end
  end
end
