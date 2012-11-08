require 'spec_helper'

describe ApplicationHelper, "#current_user?" do
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

