require 'spec_helper'

describe InvitationsController do
  describe '#facebook' do
    before do
      get :index, referrer_id: "123", referred_from: "facebook"
    end

    it "should set the referrer_id" do
      expect(session[:referrer_id]).to eq "123"
    end

    it "should set the referred_from" do
      expect(session[:referred_from]).to eq "facebook"
    end

    it "should redirect to the root url" do
      expect(response).to redirect_to(root_path)
    end
  end
end