require 'spec_helper'

describe Users::ContactsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = Fabricate(:user)
    sign_in @user
  end

  describe "#google" do
    before do
      User.any_instance.stub(:gather_google_contacts).and_return(["dan@chefsteps.com", "danahern@chefsteps.com", "dahern@chefsteps.com"])
    end

    it "should call gather_google_contacts" do
      User.any_instance.should_receive(:gather_google_contacts).and_return(["dan@chefsteps.com", "danahern@chefsteps.com", "dahern@chefsteps.com"])
      post :google
    end

    it "should set @contacts to array" do
      post :google
      expect(assigns(:contacts)).to eq ["dan@chefsteps.com", "danahern@chefsteps.com", "dahern@chefsteps.com"]
    end

    it "should return contacts as json" do
      post :google
      expect(response.body).to eq ["dan@chefsteps.com", "danahern@chefsteps.com", "dahern@chefsteps.com"].to_json
    end
  end

  describe "#invite" do
    before do
      UserMailer.stub_chain(:invitations, :deliver)
    end

    it "should call UserMailer" do
      UserMailer.should_receive(:invitations)
      post :invite, email: ["dan@chefsteps.com", "danahern@chefsteps.com", "dahern@chefsteps.com"]
    end

    it "should return status :success json" do
      post :invite, email: ["dan@chefsteps.com", "danahern@chefsteps.com", "dahern@chefsteps.com"]
      expect(response.body).to eq "{\"status\":\"success\"}"
    end
  end
end
