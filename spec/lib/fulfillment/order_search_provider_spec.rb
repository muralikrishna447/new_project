require 'spec_helper'

describe Fulfillment::OrderSearchProvider do
  let(:order_id) { 1 }
  let(:order) { ShopifyAPI::Order.new(id: order_id) }

  describe Fulfillment::ShopifyOrderSearchProvider do
    let(:params) { { foo: 'bar' } }

    describe 'orders' do
      it 'searches shopify orders with status open' do
        search_params = params.merge(status: 'open')
        Shopify::Utils.should_receive(:search_orders).with(search_params).and_return([order])
        expect(Fulfillment::ShopifyOrderSearchProvider.orders(params)).to eq [order]
      end
    end
  end

  describe Fulfillment::PendingOrderSearchProvider do
    describe 'orders' do
      let(:storage_provider) { 'my_storage_provider' }
      let(:params) { { storage: storage_provider } }

      it 'looks up orders by id from csv' do
        storage = double('storage')
        Fulfillment::CSVStorageProvider.should_receive(:provider).with(storage_provider).and_return(storage)
        storage.should_receive(:read).with(params).and_return("order_id\n#{order_id}")
        ShopifyAPI::Order.should_receive(:find).with(order_id).and_return(order)
        expect(Fulfillment::PendingOrderSearchProvider.orders(params)).to eq [order]
      end
    end
  end
end
