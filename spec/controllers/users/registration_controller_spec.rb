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

    it "should call aweber sign up" do
      Users::RegistrationsController.any_instance.should_receive(:aweber_signup)
      post :create, user: {email: "test@example.com", password: "apassword", name: "Test User"}
    end
  end
end
