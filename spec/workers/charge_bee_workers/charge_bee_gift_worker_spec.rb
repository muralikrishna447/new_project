require 'spec_helper'

describe ChargeBeeWorkers::ChargeBeeGiftWorker do

  let(:gift1) {
    {
        :gift_id => '123',
        :user_id => 456,
        :plan_amount => 6900,
        :currency_code => 'USD'
    }
  }

  let(:gift2) {
    {
        :gift_id => '456',
        :user_id => 789,
        :plan_amount => 6900,
        :currency_code => 'USD'
    }
  }


  context 'no pending redemptions' do
    before(:each) do
      Resque.should_not_receive(:enqueue)
    end

    it 'does nothing' do
      ChargeBeeWorkers::ChargeBeeGiftWorker.perform({})
    end
  end

  context '2 pending redemptions' do

    before do
      ChargebeeGiftRedemptions.create!(gift1)
      ChargebeeGiftRedemptions.create!(gift2)
    end

    before(:each) do
      Resque.should_receive(:enqueue).twice
    end

    it 'queues two jobs' do
      ChargeBeeWorkers::ChargeBeeGiftWorker.perform({})
    end
  end
end