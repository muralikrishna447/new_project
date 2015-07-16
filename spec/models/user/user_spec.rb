require 'spec_helper'

describe User do
  let(:user) { Fabricate(:user) }
  let(:assembly) { Fabricate(:assembly, price: 20.00) }

  context "#enrolled?" do
    context "free trial" do
      it "should return true if enrollment exists and free trial isn't expired" do
        Fabricate(:enrollment, user_id: user.id, enrollable: assembly, trial_expires_at: Time.now+2.days)
        user.enrolled?(assembly).should be true
      end

      it "should return false if enrollment exists and free trial is expired" do
        Fabricate(:enrollment, user_id: user.id, enrollable: assembly, trial_expires_at: Time.now-2.days)
        user.enrolled?(assembly).should be false
      end
    end
    context "normal enrollment" do
      it "should return true if enrollment exists" do
        Fabricate(:enrollment, user_id: user.id, enrollable: assembly)
        user.enrolled?(assembly).should be true
      end

      it "should return false if enrollment doesn't exist" do
        user.enrolled?(assembly).should be false
      end
    end
  end

  context "tokens" do
    it 'should return a valid auth token when no actor address exists' do
      token = user.valid_website_auth_token
      aa = ActorAddress.find_for_user_and_unique_key(user, 'website')
      aa.valid_token?(token).should be true
      # TODO - use timecop to avoid time hacks like this - 5
      token[:exp].should >= (Time.now.to_i + 1.year.to_i - 5)
    end

    it 'should return a valid auth token when no actor address exists' do
      aa = ActorAddress.create_for_user(user, unique_key: 'website')
      token = user.valid_website_auth_token
      token.claim[:address_id].should == aa.address_id
      aa.valid_token?(token).should be true
    end
  end
end
