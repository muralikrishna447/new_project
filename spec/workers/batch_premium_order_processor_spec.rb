require 'spec_helper'

describe BatchPremiumOrderProcessor do
  describe 'perform' do
    let(:order_1) { ShopifyAPI::Order.new(id: 1) }
    let(:order_2) { ShopifyAPI::Order.new(id: 2) }
    let(:order_3) { ShopifyAPI::Order.new(id: 3) }
    let(:time) { Time.new(2017, 2, 1, 12, 0, 0) }
    let(:period) { 1.day }
    before :each do
      Shopify::Utils.stub(:search_orders_with_each)
        .with(processed_at_min: (time - period).utc.to_s, status: 'open')
        .and_yield(order_1)
        .and_yield(order_2)
        .and_yield(order_3)
    end
    it 'searches for orders in the period and calls the processor on each' do
      PremiumOrderProcessor.should_receive(:perform).with(order_1.id)
      PremiumOrderProcessor.should_receive(:perform).with(order_2.id)
      PremiumOrderProcessor.should_receive(:perform).with(order_3.id)
      BatchPremiumOrderProcessor.should_receive(:report_metrics).with(3)
      Timecop.freeze(time) do
        BatchPremiumOrderProcessor.perform(period)
      end
    end
  end

  describe 'report_metrics' do
    let(:orders_processed) { 3 }
    let(:tracker) { double('tracker') }
    it 'reports metrics to Librato' do
      Librato.should_receive(:increment).with('fraud.batch-premium-order-processor.success', sporadic: true)
      Librato.should_receive(:increment).with('fraud.batch-premium-order-processor.orders.count', by: orders_processed, sporadic: true)
      Librato.stub(:tracker).and_return(tracker)
      tracker.should_receive(:flush)
      BatchPremiumOrderProcessor.report_metrics(orders_processed)
    end
  end
end
