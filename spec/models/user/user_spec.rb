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
end
