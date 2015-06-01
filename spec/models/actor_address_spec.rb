require 'spec_helper'

describe Activity, "#meta_description" do
  before :each do
    @user = Fabricate :user
    @circulator = Fabricate :circulator
    @for_user = ActorAddress.create_for_user(@user, @circulator)
  end

  it 'should create for circulator' do
    #@user.actor_addresses.length.should == 1
    a = ActorAddress.create_for_circulator(@user, @circulator)
    a.actor.should == @circulator
    a.client_metadata.should == 'circulator'
  end

  it 'should create for user' do
    #@user.actor_addresses.length.should == 1
    a = ActorAddress.create_for_user(@user, @circulator)
    a.actor.should == @user
  end

  it 'should create a token' do
    @for_user = ActorAddress.create_for_user(@user, @circulator)
    #@for_user.token.should
    puts @for_user.inspect
    puts @for_user.current_token.claim
    puts @for_user.current_token.inspect
    puts @for_user.current_token.only_signed
  end

  it 'should generate a tentative next' do
    a = ActorAddress.create_for_user(@user, @circulator)
    a.tentative_next_token.claim[:seq].should == (a.sequence + 1)
  end

  it 'should increment to next token' do
    a = ActorAddress.create_for_user(@user, @circulator)
    initial_sequence = a.sequence
    a.increment_to(a.tentative_next_token)
    a.sequence.should == (initial_sequence + 1)
  end

  it 'should reject ' do
    a = ActorAddress.create_for_user(@user, @circulator)
    next_token = a.tentative_next_token
    next_token.claim[:seq] = 123
    expect {a.increment_to next_token }.to raise_error
  end
end
