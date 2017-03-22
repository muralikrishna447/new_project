require 'spec_helper'

describe Fraud::BatchPaymentProcessor do
  describe 'perform' do
    let(:order_1) { ShopifyAPI::Order.new(id: 1) }
    let(:order_2) { ShopifyAPI::Order.new(id: 2) }
    let(:order_3) { ShopifyAPI::Order.new(id: 3) }
    let(:time) { Time.new(2017, 2, 1, 12, 0, 0) }
    let(:period) { 1.day }
    before :each do
      Shopify::Utils.stub(:search_orders_with_each)
        .with(processed_at_min: (time - period).utc.to_s, status: 'any')
        .and_yield(order_1)
        .and_yield(order_2)
        .and_yield(order_3)
    end
    it 'searches for unpaid orders in the period and calls the payment processor on each' do
      Fraud::PaymentProcessor.should_receive(:perform).with(order_1.id)
      Fraud::PaymentProcessor.should_receive(:perform).with(order_2.id)
      Fraud::PaymentProcessor.should_receive(:perform).with(order_3.id)
      Fraud::BatchPaymentProcessor.should_receive(:report_metrics).with(3)
      Timecop.freeze(time) do
        Fraud::BatchPaymentProcessor.perform(period)
      end
    end
  end

  describe 'report_metrics' do
    let(:orders_processed) { 3 }
    let(:tracker) { double('tracker') }
    it 'reports metrics to Librato' do
      Librato.should_receive(:increment).with('fraud.batch-payment-processor.success', sporadic: true)
      Librato.should_receive(:increment).with('fraud.batch-payment-processor.orders.count', by: orders_processed, sporadic: true)
      Librato.stub(:tracker).and_return(tracker)
      tracker.should_receive(:flush)
      Fraud::BatchPaymentProcessor.report_metrics(orders_processed)
    end
  end
end
