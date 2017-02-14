require 'spec_helper'

describe Fulfillment::PaymentStatusFilter do
  describe 'paid?' do
    let(:order) { ShopifyAPI::Order.new(financial_status: financial_status) }

    context 'order is paid' do
      let(:financial_status) { 'paid' }
      it 'returns true' do
        expect(Fulfillment::PaymentStatusFilter.payment_captured?(order)).to be_true
      end
    end

    context 'order is partially_refunded' do
      let(:financial_status) { 'partially_refunded' }
      it 'returns true' do
        expect(Fulfillment::PaymentStatusFilter.payment_captured?(order)).to be_true
      end
    end

    context 'order is refunded' do
      let(:financial_status) { 'refunded' }
      it 'returns true' do
        expect(Fulfillment::PaymentStatusFilter.payment_captured?(order)).to be_true
      end
    end

    context 'order is authorized' do
      let(:financial_status) { 'authorized' }
      it 'returns false' do
        expect(Fulfillment::PaymentStatusFilter.payment_captured?(order)).to be_false
      end
    end
  end
end
