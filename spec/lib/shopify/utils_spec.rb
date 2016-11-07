require 'spec_helper'

describe Shopify::Utils do
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
        expect(Shopify::Utils.order_tags(order)).to match_array([tag_1, tag_2])
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

  describe 'search_orders' do
    let(:page_size) { 2 }
    let(:order_1) { ShopifyAPI::Order.new(id: 1) }
    let(:order_2) { ShopifyAPI::Order.new(id: 2) }
    let(:order_3) { ShopifyAPI::Order.new(id: 3) }
    let(:param_key) { 'my_key'.to_sym }
    let(:param_value) { 'my_value' }

    context 'response has order count equal to page size' do
      it 'returns results from all pages' do
        path_1 = ShopifyAPI::Order.collection_path(limit: page_size, page: 1, param_key => param_value)
        ShopifyAPI::Order.should_receive(:find).once.with(:all, from: path_1).and_return([order_1, order_2])
        path_2 = ShopifyAPI::Order.collection_path(limit: page_size, page: 2, param_key => param_value)
        ShopifyAPI::Order.should_receive(:find).once.with(:all, from: path_2).and_return([order_3])

        expect(Shopify::Utils.search_orders({ param_key => param_value }, page_size)).to match_array([order_1, order_2, order_3])
      end
    end

    context 'response has order count less than page size' do
      it 'does not request another page' do
        path_1 = ShopifyAPI::Order.collection_path(limit: page_size, page: 1, param_key => param_value)
        ShopifyAPI::Order.should_receive(:find).once.with(:all, from: path_1).and_return([order_1])

        expect(Shopify::Utils.search_orders({ param_key => param_value }, page_size)).to match_array([order_1])
      end
    end
  end
end
