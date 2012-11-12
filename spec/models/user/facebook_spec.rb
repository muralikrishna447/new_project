require 'spec_helper'

describe User::Facebook do
  let(:auth) { create_auth }

  describe '#facebook_connected_user' do
    it 'returns nil if no user exists' do
      User.facebook_connected_user(auth).should_not be
    end

    it 'returns connected user if one exists' do
      user = Fabricate(:user, provider: auth.provider, uid: auth.uid)
      User.facebook_connected_user(auth).should == user
    end

    context 'user exists with same email' do
      let!(:user) { Fabricate(:user, email: 'test-user@test.com') }

      it 'returns user' do
        User.facebook_connected_user(auth).should == user
      end

      it 'assigns information from facebook' do
        User.any_instance.should_receive(:assign_from_facebook)
        User.facebook_connected_user(auth)
      end
    end
  end

  describe "#assign_from_facebook" do
    let!(:user) { Fabricate.build(:user, name: '', password: '') }

    it "assigns provider" do
      user.assign_from_facebook(auth).provider.should == :facebook
    end

    it "assigns uid" do
      user.assign_from_facebook(auth).uid.should == 'ABC'
    end

    it "assigns name if blank" do
      user.assign_from_facebook(auth).name.should == 'user name'
    end

    it "does not assign name if not blank" do
      user.name = 'bob'
      user.assign_from_facebook(auth).name.should == 'bob'
    end

    it "assigns password if record is new" do
      user.assign_from_facebook(auth).password.should_not == 'secret'
    end

    it "does not assign password if password already set on record" do
      user.password = 'new password'
      user.assign_from_facebook(auth).password.should == 'new password'
    end

    it "does not assign password if record exists" do
      user.name = 'test'
      user.password = 'secret'
      user.save!
      user.assign_from_facebook(auth).password.should == 'secret'
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

describe User::Facebook, '#connected_with_facebook?' do
  let(:user) { Fabricate.build(:user) }
  subject { user.connected_with_facebook? }

  context "hasn't connected with facebook" do
    before { user.uid = nil }
    it { subject.should == false }
  end

  context "user has connected with facebook" do
    before do
      user.uid = 'foo'
      user.provider = 'facebook'
    end
    it { subject.should == true }
  end

  context "user has connected with some other service" do
    before do
      user.uid = 'foo'
      user.provider = 'some other service'
    end
    it { subject.should == false }
  end
end

