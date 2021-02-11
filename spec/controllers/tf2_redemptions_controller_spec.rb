describe Tf2RedemptionsController do

  describe 'index' do
    it 'should load the page' do
      get :index
      expect(response).to render_template("tf2_redemptions/under_construction")
    end
  end

  describe 'show' do
    before :each do
      @user = Fabricate :user, id: 123, name: 'Dana Hern', email: 'test@example.com', joule_purchase_count: 2
      @tf2_redemption_1 = Fabricate :tf2_redemption, user_id: 123, redemption_code: "ABC"
      @tf2_redemption_2 = Fabricate :tf2_redemption, redemption_code: "DEF"

    end

    it "should redirect if not authenticated" do
      get :show
      expect(response).to redirect_to(sign_in_path(return_to: tf2_redemptions_path))
    end

    it "should display page if authenticated" do
      sign_in @user
      get :show
      expect(response).to render_template("tf2_redemptions/under_construction")
    end

    it "should set current_redemptions and max_redemptions" do
      sign_in @user
      get :show
      expect(assigns(:max_redemptions)).to be 2
      expect(assigns(:current_redemptions)).to eq @user.tf2_redemptions
    end

    it "should set the message if the param is passed in" do
      sign_in @user
      get :show, params: {message: "Test"}
      expect(assigns(:message)).to eq "Test"
    end
  end

  describe 'create' do
    before :each do
      @user = Fabricate :user, id: 123, name: 'Dana Hern', email: 'test@example.com', joule_purchase_count: 2
      @tf2_redemption_1 = Fabricate :tf2_redemption, redemption_code: "ABC"
      @tf2_redemption_2 = Fabricate :tf2_redemption, redemption_code: "DEF"
    end

    it "should redirect if not authenticated" do
      post :create
      expect(response).to redirect_to(sign_in_path(return_to: tf2_redemptions_path))
    end

    it "should redirect back with message if the current user can't do a redemption" do
      @user.joule_purchase_count = 0
      @user.save
      sign_in @user
      post :create
      expect(response).to redirect_to(tf2_redemptions_path(message: "Sorry, we don't see that you have any redemptions remaining."))
    end

    it "should redirect back with success message if successful" do
      sign_in @user
      post :create
      expect(response).to redirect_to(tf2_redemptions_path(message: "Successfully redeemed code. Have fun cooking and taunting."))
    end

    it "should set first redemption code to user on success" do
      sign_in @user
      post :create
      @tf2_redemption_1.reload.user_id.should eq @user.id
    end

    it "should redirect back with message if it failed to save" do
      Tf2Redemption.stub(:redeem!) { false }
      sign_in @user
      post :create
      expect(response).to redirect_to(tf2_redemptions_path(message: "Sorry, something seemed to go wrong. Please try again"))
    end

    it "should raise an error if there are no more redemption codes remaining" do
      @tf2_redemption_1.user_id = 1
      @tf2_redemption_1.save
      @tf2_redemption_2.user_id = 1
      @tf2_redemption_2.save
      sign_in @user
      expect{
        post :create
      }.to raise_error
    end
  end
end
