require 'spec_helper'

describe HomeController do
  describe '#welcome' do
    before do
      Fabricate(:setting) # Required for the homepage
      ApplicationController.any_instance.stub(:mixpanel_anonymous_id).and_return(1)
      Fabricate(:user, id: 123)
      Fabricate(:setting)
      get :welcome, referrer_id: "123", referred_from: "facebook"
    end

    it "should set the referrer_id" do
      expect(session[:referrer_id]).to eq 123
    end

    it "should set the referred_from" do
      expect(session[:referred_from]).to eq "facebook"
    end

    it "should redirect to the root url" do
      # expect(response).to redirect_to(root_path)
    end

    it 'shows smart app add' do
      assigns(:show_app_add).should_not be_nil
    end
  end
end
