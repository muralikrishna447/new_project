require 'spec_helper'

describe Circulator  do
  before :each do
    @circulator = Fabricate :circulator, serial_number: 'circ123', circulator_id: '123'
    @user = Fabricate :user, id: 456
  end

  it "can be created" do
    c = Circulator.find_by(id: @circulator)
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

  describe 'premium_offer_eligible?' do
    it 'returns yes for the first activation of 1.5 SS Joule' do
      circulator = Fabricate :circulator, serial_number: '1', circulator_id: '1', hardware_version: "JA", hardware_options: 1
      circulator.premium_offer_eligible?.should == true
    end

    it 'returns no for the second activation of 1.5 SS Joule' do
      circulator1 = Fabricate :circulator, serial_number: '1', circulator_id: '2', hardware_version: "JA", hardware_options: 1
      circulator1.destroy()
      circulator2 = Fabricate :circulator, serial_number: '1', circulator_id: '3', hardware_version: "JA", hardware_options: 1
      circulator2.premium_offer_eligible?.should == false
    end
  end

  it 'returns no for a non-1.5 SS Joule' do
    circulator = Fabricate :circulator, serial_number: '1', circulator_id: '4', hardware_version: "JA", hardware_options: 0
    circulator.premium_offer_eligible?.should == false
  end
end
