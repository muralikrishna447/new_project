require 'spec_helper'

describe Circulator  do
  before :each do
    @circulator = Fabricate :circulator, serial_number: 'circ123', circulator_id: '123'
    @user = Fabricate :user, id: 456
  end

  it "can be created" do
    c = Circulator.find(@circulator)
    c.serial_number.should == "circ123"
  end

  it "properly restricts length of the node" do
    long_note = 'dvef9tjkxj8l4dn1c84f5e14uhnfaytdf0spqiu3w2dq9fpfjis'
    c = Circulator.new(notes: long_note)
    expect { c.save! }.to raise_error
  end

  it 'recognized ownership properly' do
    owned_circulator = Fabricate :circulator, serial_number: 'circ123', circulator_id: '1233'
    shared_circulator = Fabricate :circulator, serial_number: 'circ123', circulator_id: '1234'
    CirculatorUser.create! user: @user, circulator: owned_circulator, owner: true
    CirculatorUser.create! user: @user, circulator: shared_circulator, owner: false
    @user.circulators.length.should == 2
    @user.owned_circulators.length.should == 1
    @user.owned_circulators.first.id.should == owned_circulator.id
  end

  it 'prevents duplicate circulators but allows creation after delete' do
    expect {
      @circulator2 = Fabricate :circulator, serial_number: 'circ123', circulator_id: '123'
    }.to raise_error(ActiveRecord::RecordNotUnique)
    @circulator.destroy()
    @circulator2 = Fabricate :circulator, serial_number: 'circ123', circulator_id: '123'
  end

  describe 'referral codes' do
    it 'creates when user first connects to circulator as owner' do
      Resque.should_receive(:enqueue).with(CreateReferralCode, 456)
      CirculatorUser.create! user: @user, circulator: @circulator, owner: true
    end

    it 'does not create when not owner' do
      Resque.should_not_receive(:enqueue)
      CirculatorUser.create! user: @user, circulator: @circulator, owner: false
    end

    it 'does not create if user already has code' do
      Resque.should_not_receive(:enqueue)
      user = Fabricate :user, id: 789, referral_code: 'kochujang'
      CirculatorUser.create! user: user, circulator: @circulator, owner: true
    end
  end
end
