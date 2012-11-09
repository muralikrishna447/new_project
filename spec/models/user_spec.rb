require 'spec_helper'

describe User, '#connect_user_with_facebook' do
  let(:auth) { create_auth }

  context 'if user does not exist' do
    it 'builds a new user from auth parameters' do
      User.should_receive(:create_user_from_auth).with(auth)
      User.connect_user_with_facebook(auth)
    end

    it 'does not persist new user' do
      user = User.connect_user_with_facebook(auth)
      user.should_not be_persisted
    end
  end

  context 'if user exists' do
    it 'does not update user that has connected before' do
      user = Fabricate(:user, provider: auth.provider, uid: auth.uid)
      User.should_not_receive(:create_user_from_auth).with(auth)
      User.connect_user_with_facebook(auth).should == user
    end

    context 'but has connected before' do
      let!(:user) { Fabricate(:user, email: 'test-user@test.com', name: 'bob') }
      let(:connected_user) { User.connect_user_with_facebook(auth) }

      it 'updates provider' do
        connected_user.provider.should == :facebook
      end

      it 'updates UID' do
        connected_user.uid.should == 'ABC'
      end

      it 'does not update password' do
        connected_user.encrypted_password.should == user.encrypted_password
      end

      it 'does not update email' do
        connected_user.email.should == user.email
      end

      it 'does not update name' do
        connected_user.name.should == user.name
      end
    end
  end


  def create_auth
    Hashie::Mash.new(
      provider: :facebook, 
      uid: 'ABC',
      info: { email: 'test-user@test.com' },
      extra: {
        raw_info: { name: 'user name' }
      }
    )
  end
end
