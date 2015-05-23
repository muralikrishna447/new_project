require 'spec_helper'

describe Activity, "#meta_description" do
  before :each do
    @user = Fabricate :user
    @circulator = Fabricate :circulator
  end

  it 'should create for circulator' do
    #@user.actor_addresses.length.should == 1
    a = ActorAddress.createForCirculator(@user, @circulator)
    a.actor.should == @circulator
    a.address_type.should == 'circulator'
  end

  it 'should create for user' do
    #@user.actor_addresses.length.should == 1
    a = ActorAddress.createForUser(@user, @circulator)
    a.actor.should == @user
  end

  it 'should create a token' do
    a = ActorAddress.createForUser(@user, @circulator)
    puts a.inspect
    puts a.current_token.claim
    puts a.current_token.inspect
    puts a.current_token.only_signed
  end

  it 'should generate a tentative next' do
    a = ActorAddress.createForUser(@user, @circulator)
    puts a.tentative_next.claim
  end
end
