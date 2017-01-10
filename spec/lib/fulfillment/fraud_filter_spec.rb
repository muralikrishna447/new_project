require 'spec_helper'

describe Fulfillment::FraudFilter do
  let(:order_id) { 12345 }
  let(:order) { ShopifyAPI::Order.new(id: order_id, tags: tags) }

  describe 'fraud_suspected?' do
    context 'order has approved tag' do
      let(:tags) { Fulfillment::FraudFilter::APPROVED_TAG }

      it 'returns false' do
        expect(Fulfillment::FraudFilter.fraud_suspected?(order)).to be_false
      end
    end

    context 'order does not have approved tag' do
      let(:tags) { '' }
      let(:order_risk_1) { ShopifyAPI::OrderRisk.new(recommendation: recommendation_1) }
      let(:order_risk_2) { ShopifyAPI::OrderRisk.new(recommendation: recommendation_2) }

      before :each do
        ShopifyAPI::OrderRisk
          .should_receive(:find)
          .with(:all, params: { order_id: order_id })
          .and_return([order_risk_1, order_risk_2])
      end

      context 'order has a recommendation with medium risk level' do
        let(:recommendation_1) { 'investigate' }
        let(:recommendation_2) { 'accept' }

        it 'returns true' do
          expect(Fulfillment::FraudFilter.fraud_suspected?(order)).to be_true
        end
      end

      context 'order has a recommendation with high risk level' do
        let(:recommendation_1) { 'cancel' }
        let(:recommendation_2) { 'accept' }

        it 'returns true' do
          expect(Fulfillment::FraudFilter.fraud_suspected?(order)).to be_true
        end
      end

      context 'order has recommendations with low risk level' do
        let(:recommendation_1) { 'accept' }
        let(:recommendation_2) { 'accept' }

        it 'returns false' do
          expect(Fulfillment::FraudFilter.fraud_suspected?(order)).to be_false
        end
      end
    end
  end
end
