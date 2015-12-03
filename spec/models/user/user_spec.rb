require 'spec_helper'

describe User do
  before do
    @user = Fabricate(:user)
    @assembly = Fabricate(:assembly, price: 20.00)
  end

  context "#enrolled?" do
    context "normal enrollment" do
      it "should return true if enrollment exists" do
        Fabricate(:enrollment, user_id: @user.id, enrollable: @assembly)
        @user.enrolled?(@assembly).should be true
      end

      it "should return false if enrollment doesn't exist" do
        @user.enrolled?(@assembly).should be false
      end
    end
  end

  context "tokens" do
    it 'should return a valid auth token when no actor address exists' do
      token = @user.valid_website_auth_token
      aa = ActorAddress.find_for_user_and_unique_key(@user, 'website')
      aa.valid_token?(token).should be true
      # TODO - use timecop to avoid time hacks like this - 5
      token[:exp].should >= (Time.now.to_i + 1.year.to_i - 5)
    end

    it 'should return a valid auth token when no actor address exists' do
      aa = ActorAddress.create_for_user(@user, unique_key: 'website')
      token = @user.valid_website_auth_token
      token.claim[:a].should == aa.address_id
      aa.valid_token?(token).should be true
    end
  end

  context "premium member" do
    it "should default false" do
      @user.premium?.should be false
    end

    it "make_premium_member should set correct fields" do
      @user.make_premium_member(10)
      @user.premium?.should be true
      @user.premium_membership_created_at.should be > DateTime.now - 1.hour
      expect(@user.premium_membership_price).to eq(10)
    end

    it 'make_premium should enqueue user sync job' do
      Resque.should_receive(:enqueue).with(UserSync, @user.id)
      @user.make_premium_member(10)
    end

  end

  context "joule_purchased" do
    it "should set date and count on first purchase" do
      @user.joule_purchase_count.should eq(0)
      @user.first_joule_purchased_at.present?.should be false

      @user.joule_purchased

      @user.first_joule_purchased_at.present?.should be true
      @user.joule_purchase_count.should eq(1)
    end

    it "should change count but not date on second purchase" do
      @user.joule_purchased
      date = @user.first_joule_purchased_at
      @user.joule_purchased
      @user.first_joule_purchased_at.should eq(date)
      @user.joule_purchase_count.should eq(2)
    end
  end

  context "use_premium_discount" do
    it "should set used_circulator_discount to true" do
      @user.use_premium_discount
      @user.used_circulator_discount.should eq true
    end
  end

  context "can_receive_circulator_discount" do
    it "should return true if the user is a premium member and hasn't used their discount" do
      @user.make_premium_member(10)
      @user.can_receive_circulator_discount?.should eq true
    end

    it 'should return false if the user has used their discount' do
      @user.make_premium_member(10)
      @user.use_premium_discount
      @user.can_receive_circulator_discount?.should eq false
    end
  end


end
