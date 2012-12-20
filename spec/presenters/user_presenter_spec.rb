require 'spec_helper'

describe UserPresenter, "#attributes" do
  let(:user) { Fabricate.build(:user) }
  let(:user_presenter) { UserPresenter.new(user) }

  subject { user_presenter.attributes }

  it "serializes valid keys" do
    subject.keys.should =~ [:id, :email, :name, :location, :quote, :website, :image, :profile_complete, :chef_type]
  end
end

describe UserPresenter, '#profile_image_url' do
  let(:user) { Fabricate.build(:user) }
  let(:user_presenter) { UserPresenter.new(user) }

  subject { user_presenter.profile_image_url }

  context "user is connected with facebook" do
    before do
      user.stub(:connected_with_facebook?).and_return(true)
      UserPresenter.stub(:facebook_image_url).and_return("facebook image url")
    end

    it { subject.should == "facebook image url" }
  end

  context "user isn't connected with facebook" do
    before do
      user.stub(:connected_with_facebook?).and_return(false)
      user.stub(:gravatar_url).and_return("some gravatar url")
    end

    it "uses the gravatar url" do
      subject.should == "some gravatar url"
    end

    it "include default placeholder image absolute path" do
      user_presenter.stub(:default_profile_photo_url).and_return("default photo url")
      user.should_receive(:gravatar_url).with(default: "default photo url")
      user_presenter.profile_image_url
    end
  end
end

describe UserPresenter, "#facebook_image_url" do
  it "generates a facebook graph photo URL with uid" do
    UserPresenter.facebook_image_url('ABCD').should == 'https://graph.facebook.com/ABCD/picture?type=large'
  end
end

describe UserPresenter, "#default_profile_photo_url" do
  let(:user_presenter) { UserPresenter.new(mock('fake user')) }

  subject { user_presenter.default_profile_photo_url }
  it "returns URL for default profile photo" do
    subject.should include 'profile-placeholder.png'
  end
end

