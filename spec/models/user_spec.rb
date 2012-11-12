require 'spec_helper'

describe User, '#profile_image_url' do
  let(:user) { Fabricate.build(:user) }
  subject { user.profile_image_url('DEFAULT_IMAGE_URL') }

  context "user is connected with facebook" do
    before do
      user.stub(:connected_with_facebook?).and_return(true)
      user.stub(:facebook_image_url).and_return("facebook image url")
    end

    it { subject.should == "facebook image url" }
  end

  context "user isn't connected with facebook" do
    before do
      user.stub(:connected_with_facebook?).and_return(false)
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

