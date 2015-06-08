require 'spec_helper'

describe Circulator  do
  before :each do
    @circulator = Fabricate :circulator, serial_number: 'circ123', circulator_id: '123'
    @user = Fabricate :user
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
end
