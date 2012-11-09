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

