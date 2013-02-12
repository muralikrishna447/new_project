require 'spec_helper'

describe Users::OmniauthCallbacksController, '#facebook' do
  let(:auth) { stub('auth') }

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
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
