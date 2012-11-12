require 'spec_helper'

describe ApplicationHelper, "#is_current_user?" do
  let(:user) { mock('user') }

  subject{ helper.is_current_user?(user) }

  context "with no user signed in" do
    before { helper.stub(:current_user) { nil } }
    it { subject.should == false}
  end

  context "with different user signed in" do
    before { helper.stub(:current_user) { mock('other user') } }
    it { subject.should == false}
  end

  context "with same user signed in" do
    before { helper.stub(:current_user) { user } }
    it { subject.should == true }
  end
end

describe ApplicationHelper, "#facebook_image_url" do
  it "generates a facebook graph photo URL with uid" do
    helper.facebook_image_url('ABCD').should == 'https://graph.facebook.com/ABCD/picture'
  end
end

describe ApplicationHelper, "#default_profile_photo_url" do
  it "returns URL for default profile photo" do
    helper.default_profile_photo_url.should include 'http://delve.dev', 'profile-placeholder.png'
  end
end
