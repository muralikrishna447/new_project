require 'spec_helper'

describe Users::RegistrationsController do

  describe "#create" do
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      ApplicationController.any_instance.stub(:mixpanel_anonymous_id).and_return(4)
    end

    it 'should redirect a user coming from the sign_in path to the welcome page (to prevent a redirect loop)' do
      session[:user_return_to] = sign_in_url
      post :create, user: {email: "test@example.com", password: "apassword", name: "Test User"}
      response.should_not redirect_to sign_in_url
      response.should redirect_to welcome_url(email: assigns(:user).email)
    end

    # it "should do email sign up" do
    #   Users::RegistrationsController.any_instance.should_receive(:email_list_signup)
    #   post :create, user: {email: "test@example.com", password: "apassword", name: "Test User"}
    # end

    it "should set referred_from if session is set" do
      session[:referred_from] = "facebook"
      post :create, user: {email: "test@example.com", password: "apassword", name: "Test User"}
      expect(assigns(:user).referred_from).to eq "facebook"
    end

    it "should set referrer_id if session is set" do
      session[:referrer_id] = 321
      post :create, user: {email: "test@example.com", password: "apassword", name: "Test User"}
      expect(assigns(:user).referrer_id).to eq 321
    end

    it "should handle empty params" do
      post :create
      expect(response.status).to eq 401
    end
  end

  describe "#destroy" do
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = Fabricate(:user)
      sign_in(@user)
    end

    it "should redirect a user back to the edit page" do
      delete :destroy
      response.should redirect_to root_url
    end
  end
end
