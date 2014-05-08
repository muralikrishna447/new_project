require 'spec_helper'

describe Users::OmniauthCallbacksController do
  describe "#facebook" do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context "not xhr" do
      let(:auth) { stub('auth') }

      before do
        request.env["omniauth.auth"] = auth
      end
      context 'user does not exist' do
        before { User.stub(:facebook_connected_user) { nil } }

        it 'stores auth data in session' do
          get :facebook
          session['devise.facebook_data'].should == auth
        end

        it 'redirects user to complete registration form' do
          get :facebook
          should redirect_to 'http://test.host/complete_registration'
        end
      end

      context 'user exists' do
        let(:user) { Fabricate.build(:user) }
        before { User.stub(:facebook_connected_user) { user } }
        it 'signs in user' do
          get :facebook
          user.sign_in_count.should == 1
        end
      end
    end

    context "xhr" do
      before do
        ApplicationController.any_instance.stub(:mixpanel_anonymous_id).and_return(1)
      end

      context "user does not exist" do
        it "should return a json" do
          xhr :get, :facebook, {user: {provider: "facebook", uid: "123", email: "test@example.com", name: "Test User"}}
          response.status.should be 200
          response.body.should include "test@example.com"
          response.body.should include "\"new_user\":true"
          response.body.should include "\"success\":true"
        end

        it "should be a new sign up" do
          xhr :get, :facebook, {user: {provider: "facebook", uid: "123", email: "test@example.com", name: "Test User"}}
          assigns(:new_signup).should be true
        end

        it "should do email signup" do
          Users::OmniauthCallbacksController.any_instance.should_receive(:email_list_signup)
          xhr :get, :facebook, {user: {provider: "facebook", uid: "123", email: "test@example.com", name: "Test User"}}
        end
      end

      context "user exists" do
        before do
          Fabricate(:user, provider: "facebook", facebook_user_id: "123", email: "test@example.com", name: "Test User")
        end

        it "should return a json" do
          xhr :get, :facebook, {user: {provider: "facebook", uid: "123", email: "test@example.com", name: "Test User"}}
          response.status.should be 200
          response.body.should include "test@example.com"
          response.body.should include "\"new_user\":false"
          response.body.should include "\"success\":true"
        end

        it "should not be a new_signup" do
          xhr :get, :facebook, {user: {provider: "facebook", uid: "123", email: "test@example.com", name: "Test User"}}
          assigns(:new_signup).should be false
        end
      end

      context "connect account to current_user" do
        before do
          @user = Fabricate(:user, email: "not_facebook@example.com", name: "Test User")
          sign_in(@user)
        end

        it "should update the user with the facebook_user_id" do
          xhr :get, :facebook, {user: {provider: "facebook", user_id: "123", email: "facebook@example.com", name: "Test User"}}
          expect(@user.reload.facebook_user_id).to eq "123"
        end

        it "should not update the user email" do
          xhr :get, :facebook, {user: {provider: "facebook", user_id: "123", email: "facebook@example.com", name: "Test User"}}
          expect(@user.reload.email).to eq "not_facebook@example.com"
          expect(@user.reload.email).to_not eq "facebook@example.com"
        end
      end
    end
  end
end
