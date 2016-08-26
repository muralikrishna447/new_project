require 'spec_helper'

describe ActorAddress  do
  before :each do
    @user = Fabricate :user
    @circulator = Fabricate :circulator, notes: 'some notes', circulator_id: '1234123412341234'
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
    next_token.claim[:a] = 123
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

  it 'should find for old style token'  do
    claim = {'User' => {'id' => @user.id}, 'address_id' => @for_user.address_id}
    token = AuthToken.new(claim)
    aa = ActorAddress.find_for_token(token)
    aa.id.should == @for_user.id
  end

  it 'should find for new style token' do
    claim  ={'a' => @for_user.address_id}
    token = AuthToken.new(claim)
    aa = ActorAddress.find_for_token(token)
    aa.id.should == @for_user.id
  end

  it 'should reject revoked addresses when finding by token' do
    claim  ={'a' => @for_user.address_id}
    token = AuthToken.new(claim)
    aa = ActorAddress.find_for_token(token)
    aa.revoke
    ActorAddress.find_for_token(token).should be_nil
  end

  it 'should find addressable addresses' do
    CirculatorUser.create! user: @user, circulator: @circulator, owner: true
    @user.save

    a_circ = ActorAddress.create_for_circulator(@circulator)
    a_user = @for_user

    a_user.addressable_addresses.map{|a| a.address_id}.should == [a_circ.address_id]
    a_circ.addressable_addresses.map{|a| a.address_id}.should == [a_user.address_id]
  end

  context 'user has active addresses' do
    let(:user) { Fabricate(:user) }
    let(:actor_addresses) do
      [
        ActorAddress.create_for_user(user),
        ActorAddress.create_for_user(user)
      ]
    end
    before { actor_addresses.each(&:save) }

    it 'should revoke all active addresses for user' do
      ActorAddress.revoke_all_for_user(user)
      expect(ActorAddress.where(actor_id: user.id, status: 'revoked').size).to eq 2
    end
  end

end
