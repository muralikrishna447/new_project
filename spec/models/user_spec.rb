require 'spec_helper'

describe User, '#connected_with_facebook?' do
  let(:user) { Fabricate.build(:user) }
  subject { user.connected_with_facebook?}

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

describe User, '#image_url' do
  let(:user) { Fabricate.build(:user) }
  subject { user.image_url }

  context "user is connected with facebook" do
    before do
      user.stub(:connected_with_facebook?).and_return(true)
      ApplicationHelper.stub(:facebook_image_url).and_return("facebook image url")
    end

    before { user.stub(:connected_with_facebook?).and_return(true) }

    it { subject.should == "facebook image url" }
  end

  context "user isn't connected with facebook" do
    before do
      user.stub(:connected_with_facebook?).and_return(false)
    end

    context "and doesn't have a gravatar" do
      before { user.stub(:gravatar_url).and_return('some gravatar url with USER_HAS_NO_IMAGE') }
      it { subject.should == nil }
    end

    context "and has a gravatar" do
      before { user.stub(:gravatar_url).and_return('some gravatar url') }
      it { subject.should == "some gravatar url" }
    end

  end

end

