require 'spec_helper'

describe User::Facebook do
  let(:auth) { create_auth }

  describe '#facebook_connected_user' do
    it 'returns nil if no user exists' do
      User.facebook_connected_user(auth).should be nil
    end

    it 'returns connected user if one exists' do
      user = Fabricate(:user, provider: auth.provider, facebook_user_id: auth.uid)
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
      user.assign_from_facebook(auth).provider.should == 'facebook'
    end

    it "assigns uid" do
      user.assign_from_facebook(auth).facebook_user_id.should == 'ABC'
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

  describe "#facebook_connect" do
    let(:user) { Fabricate(:user, email: "not_facebook@example.com") }
    it "should update the facebook_user_id" do
      user.facebook_connect(user_id: "123")
      user.facebook_user_id.should eq "123"
    end

    it "should not update the email address" do
      user.facebook_connect(user_id: "123", email: "facebook@example.com")
      user.email.should_not eq "facebook@example.com"
      user.email.should eq "not_facebook@example.com"
    end
  end

  describe ".facebook_connect" do
    let(:params){ {provider: "facebook", uid: "123", email: "test@example.com", name: "Test User"} }

    it "should initialize a new record if the user doesn't exist" do
      returned_user = User.facebook_connect(params)
      returned_user.new_record?.should be true
    end

    context "returning user" do
      before do
        @user = Fabricate(:user, params.except(:uid).merge(facebook_user_id: "123"))
      end

      it "should return the user if they already exist" do
        returned_user = User.facebook_connect(params)
        returned_user.should eq @user
      end

      it "should not respond true to .new_record?" do
        returned_user = User.facebook_connect(params)
        returned_user.new_record?.should be false
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

describe User::Facebook, '#connected_with_facebook?' do
  let(:user) { Fabricate.build(:user) }
  subject { user.connected_with_facebook? }

  context "hasn't connected with facebook" do
    before { user.facebook_user_id = nil }
    it { subject.should == false }
  end

  context "user has connected with facebook" do
    before do
      user.facebook_user_id = 'foo'
      user.provider = 'facebook'
    end
    it { subject.should == true }
  end

  context "user has connected with some other service" do
    before do
      user.facebook_user_id = 'foo'
      user.provider = 'some other service'
    end
    it { subject.should == false }
  end
end

