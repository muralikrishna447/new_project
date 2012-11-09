require 'spec_helper'

describe User, '#find_for_facebook_oauth' do
  let(:auth) { create_auth }

  it 'creates a new user from auth parameters if user does not exist' do
    User.should_receive(:create_user_from_auth).with(auth)
    User.find_for_facebook_oauth(auth)
  end

  it 'updates user with same email if user has not connected' do
    user = Fabricate(:user, email: 'test-user@test.com')
    fb_user = User.find_for_facebook_oauth(auth)
    fb_user.should == user
    fb_user.provider.should == :facebook
    fb_user.uid.should == 'ABC'
  end

  it 'does not update user that has connected before' do
    user = Fabricate(:user, provider: auth.provider, uid: auth.uid)
    User.should_not_receive(:create_user_from_auth).with(auth)
    User.find_for_facebook_oauth(auth).should == user
  end


  def create_auth
    Hashie::Mash.new(
      provider: :facebook, 
      uid: 'ABC',
      info: { email: 'test-user@test.com' },
      extra: {
        raw_info: { name: 'name' }
      }
    )
  end
end
