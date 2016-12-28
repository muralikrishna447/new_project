require 'spec_helper'

describe Tf2Redemption do
  describe "redeem" do
    before :each do
      @user = Fabricate :user, id: 456
      @redemption = Fabricate :tf2_redemption, {redemption_code: "TF2", user_id: nil}
    end

    it "should redeem if there is an open code" do
      Tf2Redemption.not_redeemed.count.should == 1
      result = Tf2Redemption.redeem!(@user)
      result.should == true
      Tf2Redemption.not_redeemed.count.should == 0
      Tf2Redemption.first.user_id.should == @user.id
    end

    it "should error if there are no redemption codes" do
      @redemption.user_id = 1
      @redemption.save
      expect{Tf2Redemption.redeem!(@user)}.to raise_error
    end
  end
end
