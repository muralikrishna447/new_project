require 'spec_helper'

describe Activity, "#meta_description" do
  before :each do
    @user = Fabricate :user
    @circulator = Fabricate :circulator, notes: 'some notes', circulator_id: '123'
    @for_user = ActorAddress.create_for_user(@user)
  end

  it 'should create for circulator' do
    #@user.actor_addresses.length.should == 1

    a = ActorAddress.create_for_circulator(@circulator)
    a.actor.should == @circulator
    a.client_metadata.should == 'circulator'
  end

  it 'should create for user' do
    #@user.actor_addresses.length.should == 1
    a = ActorAddress.create_for_user(@user)
    a.actor.should == @user
  end

  it 'should generate a tentative next' do
    a = ActorAddress.create_for_user(@user)
    a.tentative_next_token.claim[:seq].should == (a.sequence + 1)
  end

  it 'should increment to next token' do
    a = ActorAddress.create_for_user(@user)
    initial_sequence = a.sequence
    a.increment_to(a.tentative_next_token)
    a.sequence.should == (initial_sequence + 1)
  end


  it 'should reject incrementing to incorrect sequence' do
    a = ActorAddress.create_for_user(@user)
    next_token = a.tentative_next_token
    next_token.claim[:seq] = 123
    expect {a.increment_to next_token }.to raise_error
  end

  it 'should reject incrementing to mismatched token' do
    a = ActorAddress.create_for_user(@user)
    next_token = a.tentative_next_token
    next_token.claim[:address_id] = 123
    expect {a.increment_to next_token }.to raise_error
  end

  it 'should respect unique key' do
    a = ActorAddress.create_for_user(@user, unique_key: 'website')
    a.unique_key.should == 'website'

    expect {
      ActorAddress.create_for_user(@user, unique_key: 'website')
    }.to raise_error
  end

  it 'should allow multiple entries when unique key is null' do
    id1 = ActorAddress.create_for_user(@user).address_id
    id2 = ActorAddress.create_for_user(@user).address_id
    id1.should_not == id2
  end
end
