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
        expect(capturer.capturable?(order)).to be false
      end
    end

    context 'order financial_status is authorized' do
      let(:cancelled_at) { nil }
      let(:financial_status) { 'authorized' }
      it 'returns true' do
        expect(capturer.capturable?(order)).to be true
      end
    end

    context 'order financial_status is partially_paid' do
      let(:cancelled_at) { nil }
      let(:financial_status) { 'partially_paid' }
      it 'returns true' do
        expect(capturer.capturable?(order)).to be true
      end
    end

    context 'order financial_status is paid' do
      let(:cancelled_at) { nil }
      let(:financial_status) { 'paid' }
      it 'returns false' do
        expect(capturer.capturable?(order)).to be false
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

    before :each do
      capturer.stub(:build_capture_transaction).with(order).and_return(transaction)
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

  describe 'build_capture_transaction' do
    let(:order_id) { 1234 }
    let(:order) { ShopifyAPI::Order.new(id: 1234, financial_status: financial_status) }

    context 'order has financial_status authorized' do
      let(:financial_status) { 'authorized' }
      it 'returns capture transaction with no amount' do
        transaction = ShopifyAPI::Transaction.new(kind: 'capture')
        transaction.prefix_options[:order_id] = order_id
        expect(capturer.build_capture_transaction(order)).to eq(transaction)
      end
    end

    context 'order has financial_status partially_paid' do
      let(:financial_status) { 'partially_paid' }
      let(:auth_amount) { '4.31' }
      let(:transaction) { ShopifyAPI::Transaction.new(amount: auth_amount) }

      context 'order has successful non-gift-card authorizations' do
        before :each do
          order.stub(:transactions).and_return([transaction])
          capturer.stub(:successful_cc_auth?).with(transaction).and_return(true)
        end

        it 'returns capture transaction with authorization amount' do
          transaction = ShopifyAPI::Transaction.new(
            kind: 'capture',
            amount: 4.31
          )
          transaction.prefix_options[:order_id] = order_id
          expect(capturer.build_capture_transaction(order)).to eq(transaction)
        end
      end

      context 'order has no successful non-gift-card authorizations' do
        before :each do
          order.stub(:transactions).and_return([transaction])
          capturer.stub(:successful_cc_auth?).with(transaction).and_return(false)
        end

        it 'raises error' do
          expect { capturer.build_capture_transaction(order) }.to raise_error
        end
      end

      context 'order has multiple successful non-gift-card authorizations' do
        let(:transaction_dupe) { ShopifyAPI::Transaction.new(amount: auth_amount) }

        before :each do
          order.stub(:transactions).and_return([transaction, transaction_dupe])
          capturer.stub(:successful_cc_auth?).with(transaction).and_return(true)
          capturer.stub(:successful_cc_auth?).with(transaction_dupe).and_return(true)
        end

        it 'raises error' do
          expect { capturer.build_capture_transaction(order) }
        end
      end
    end
  end

  describe 'successful_cc_auth?' do
    let(:transaction) do
      ShopifyAPI::Transaction.new(
        kind: kind,
        gateway: gateway,
        status: status
      )
    end

    context 'transaction kind is not authorization' do
      let(:kind) { 'capture' }
      let(:gateway) { 'my_gateway' }
      let(:status) { 'success' }
      it 'returns false' do
        expect(capturer.successful_cc_auth?(transaction)).to be false
      end
    end

    context 'transaction kind is authorization' do
      let(:kind) { 'authorization' }
      let(:status) { 'success' }
      context 'gateway is gift_card' do
        let(:gateway) { 'gift_card' }
        it 'returns false' do
          expect(capturer.successful_cc_auth?(transaction)).to be false
        end
      end

      context 'transaction gateway is not gift_card' do
        let(:gateway) { 'my_gateway' }
        context 'status is success' do
          let(:status) { 'success' }
          it 'returns true' do
            expect(capturer.successful_cc_auth?(transaction)).to be true
          end
        end

        context 'transaction status is not success' do
          let(:status) { 'failure' }
          it 'returns false' do
            expect(capturer.successful_cc_auth?(transaction)).to be false
          end
        end
      end
    end
  end
end
