require 'spec_helper'

describe User, '#connected_with_facebook?' do
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

describe User, '#profile_image_url' do
  let(:user) { Fabricate.build(:user) }
  subject { user.profile_image_url }

  context "user is connected with facebook" do
    before do
      user.stub(:connected_with_facebook?).and_return(true)
      ApplicationHelper.stub(:facebook_image_url).and_return("facebook image url")
    end

    it { subject.should == "facebook image url" }
  end

  context "user isn't connected with facebook" do
    before do
      user.stub(:connected_with_facebook?).and_return(false)
      User.stub(:default_image_url).and_return("DEFAULT_IMAGE_URL")
    end

    it "uses the gravatar url" do
      user.stub(:gravatar_url).and_return("some gravatar url")
      subject.should == "some gravatar url"
    end

    it "include default placeholder image absolute path" do
      subject.should include('d=DEFAULT_IMAGE_URL')
    end
  end
end

