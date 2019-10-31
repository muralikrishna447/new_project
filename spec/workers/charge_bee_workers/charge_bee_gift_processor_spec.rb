require 'spec_helper'

describe ChargeBeeWorkers::ChargeBeeGiftProcessor do
  let(:params) {
    {
      :gift_id => '123',
      :user_id => 456,
      :plan_amount => 6900,
      :currency_code => 'USD'
    }
  }
  let(:gift_claim_return) {
    nil
  }
  let(:credit_list_return) {
    double('credit_list_return', :any? => [], :next_offset => nil)
  }
  let(:credit_add_return) {
    nil
  }

  before(:each) do
    ChargeBee::Gift.should_receive(:claim).with(params[:gift_id]).and_return(gift_claim_return)
    ChargeBee::PromotionalCredit.should_receive(:list).and_return(credit_list_return)
  end

  context 'should add promotional credit' do
    before(:each) do
      ChargeBee::PromotionalCredit.should_receive(:add).and_return(credit_add_return)
    end

    context 'clean history (no partial failed attempts)' do
      it 'processes the gift' do
        ChargeBeeWorkers::ChargeBeeGiftProcessor.process(params)
        item = ChargebeeGiftRedemptions.find_by_gift_id(params[:gift_id])
        expect(item.complete).to be_true
      end
    end

    context 'mark_started already completed' do
      before do
        ChargebeeGiftRedemptions.create(:gift_id => params[:gift_id], :user_id => params[:user_id], :plan_amount => params[:plan_amount], :currency_code => params[:currency_code])
      end

      it 'processes the gift' do
        ChargeBeeWorkers::ChargeBeeGiftProcessor.process(params)
        item = ChargebeeGiftRedemptions.find_by_gift_id(params[:gift_id])
        expect(item.complete).to be_true
      end
    end

    # I can't get this rspec mock to work
    # context 'claim_gift already completed' do
    #   it 'processes the gift' do
    #     ChargeBee::Gift.should_receive(:claim).with(params[:gift_id]).and_raise(ChargeBee::InvalidRequestError)
    #
    #     ChargeBeeGiftProcessor.process(params)
    #     item = ChargebeeGiftRedemptions.find_by_gift_id(params[:gift_id])
    #     expect(item.complete).to be_true
    #   end
    # end
  end

  context 'promotional credit already exists' do
    let(:credit) {
      double('credit', :description => "Gift Redemption #{params[:gift_id]}")
    }
    let(:promotional_credit) {
      double('promotional_credit', :promotional_credit => credit)
    }
    let(:credit_list_return) {
      double('credit_list_return', :any? => [promotional_credit], :next_offset => nil)
    }

    before(:each) do
      ChargeBee::PromotionalCredit.should_not_receive(:add)
    end

    it 'processes the gift' do
      ChargeBeeWorkers::ChargeBeeGiftProcessor.process(params)
      item = ChargebeeGiftRedemptions.find_by_gift_id(params[:gift_id])
      expect(item.complete).to be_true
    end
  end

end