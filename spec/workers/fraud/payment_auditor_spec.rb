require 'spec_helper'

describe Fraud::PaymentAuditor, :skip => 'true' do
  describe 'perform' do
    let(:processed_at) { '2017-02-21T16:46:44-08:00' }
    let(:order) do
      ShopifyAPI::Order.new(
        id: 1234,
        processed_at: processed_at
      )
    end
    let(:tracker) { double('tracker') }

    before :each do
      Shopify::Utils.stub(:search_orders_with_each)
        .with(status: 'any', financial_status: 'unpaid')
        .and_yield(order)
      Librato.should_receive(:increment).with('fraud.payment-auditor.success', sporadic: true)
      Librato.should_receive(:tracker).and_return(tracker)
      tracker.should_receive(:flush)
    end

    context 'auditable? returns true' do
      before :each do
        Fraud::PaymentAuditor.stub(:auditable?).and_return(true)
      end

      it 'measures order age in days' do
        Timecop.freeze(Time.parse(processed_at) + 2.days) do
          Librato.should_receive(:measure).with('fraud.payment-auditor.orders.unpaid.age', 2)
          Fraud::PaymentAuditor.perform
        end
      end
    end

    context 'auditable? returns false' do
      before :each do
        Fraud::PaymentAuditor.stub(:auditable?).and_return(false)
      end

      it 'does not measure order age' do
        Librato.should_not_receive(:measure)
        Fraud::PaymentAuditor.perform
      end
    end
  end

  describe 'auditable?' do
    let(:order) do
      ShopifyAPI::Order.new(
        id: 1234,
        cancelled_at: cancelled_at,
        tags: tags
      )
    end

    context 'order is cancelled' do
      let(:cancelled_at) { '2017-02-21T16:46:44-08:00' }
      let(:tags) { '' }
      it 'returns false' do
        expect(Fraud::PaymentAuditor.auditable?(order)).to be_false
      end
    end

    context 'order is not cancelled' do
      let(:cancelled_at) { nil }

      context 'order has exempt tag' do
        let(:tags) { Fraud::PaymentAuditor::ORDER_EXEMPT_TAG }
        it 'returns false' do
          expect(Fraud::PaymentAuditor.auditable?(order)).to be_false
        end
      end

      context 'order does not have exempt tag' do
        let(:tags) { '' }
        it 'returns true' do
          expect(Fraud::PaymentAuditor.auditable?(order)).to be_true
        end
      end
    end
  end
end
