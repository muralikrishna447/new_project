require 'spec_helper'

describe Circulator  do
  before :each do
    @circulator = Fabricate :circulator, serialNumber: 'circ123'
    @user = Fabricate :user
  end

  it "can be created"  do
    c = Circulator.find(@circulator)
    c.serialNumber.should == "circ123"
  end

  it "can owned" do
    c = Circulator.find(@circulator.id)
    u = User.find(@user)

    c.users << u
    #c.save

    puts CirculatorUser.where(circulator_id: @circulator, user_id: @user).first
    puts u.circulators.inspect
  end
end
