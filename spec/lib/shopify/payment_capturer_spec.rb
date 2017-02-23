require 'spec_helper'

describe Shopify::PaymentCapturer do
  let(:capturer) { Class.new { include Shopify::PaymentCapturer } }

  describe 'capturable?' do
    let(:order) do
      ShopifyAPI::Order.new(
        cancelled_at: cancelled_at,
        financial_status: financial_status
      )
    end

    context 'order is cancelled' do
      let(:cancelled_at) { Time.now.utc.iso8601.to_s }
      let(:financial_status) { 'whatever' }
      it 'returns false' do
        expect(capturer.capturable?(order)).to be_false
      end
    end

    context 'order financial_status is authorized' do
      let(:cancelled_at) { nil }
      let(:financial_status) { 'authorized' }
      it 'returns true' do
        expect(capturer.capturable?(order)).to be_true
      end
    end

    context 'order financial_status is partially_paid' do
      let(:cancelled_at) { nil }
      let(:financial_status) { 'partially_paid' }
      it 'returns true' do
        expect(capturer.capturable?(order)).to be_true
      end
    end

    context 'order financial_status is paid' do
      let(:cancelled_at) { nil }
      let(:financial_status) { 'paid' }
      it 'returns false' do
        expect(capturer.capturable?(order)).to be_false
      end
    end
  end

  describe 'capture_payment' do
    let(:order_id) { 1234 }
    let(:order) { ShopifyAPI::Order.new(id: order_id) }
    let(:transaction) do
      transaction = ShopifyAPI::Transaction.new(kind: 'capture')
      transaction.prefix_options[:order_id] = order.id
      transaction
    end

    context 'payment capture raises error' do
      context 'payment was previously captured' do
        it 'checks order capture status and does not raise error' do
          Shopify::Utils.should_receive(:send_assert_true).with(transaction, :save).and_raise('error')
          Shopify::Utils.should_receive(:order_by_id).with(order_id).and_return(order)
          capturer.should_receive(:capturable?).with(order).and_return(false)
          capturer.capture_payment(order)
        end
      end

      context 'payment was not previously captured' do
        it 'checks order capture status and raises error' do
          Shopify::Utils.should_receive(:send_assert_true).with(transaction, :save).and_raise('error')
          Shopify::Utils.should_receive(:order_by_id).with(order_id).and_return(order)
          capturer.should_receive(:capturable?).with(order).and_return(true)
          expect { capturer.capture_payment(order) }.to raise_error
        end
      end
    end

    context 'payment capture is successful' do
      it 'saves capture transaction to shopify' do
        Shopify::Utils.should_receive(:send_assert_true).with(transaction, :save)
        capturer.capture_payment(order)
      end
    end
  end
end
