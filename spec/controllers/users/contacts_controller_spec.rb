require 'spec_helper'

describe Users::ContactsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = Fabricate(:user)
    sign_in @user
  end

  describe "#google" do
    before do
      User.any_instance.stub(:gather_google_contacts).and_return(contact_response)
    end

    let(:contact_response){ [{"name"=>"Dan Test", "email"=>"dan@chefsteps.com"},{"name"=>"What is up", "email"=>"danahern@chefsteps.com"},{"name"=>"Testing this", "email"=>"dahern@chefsteps.com"}] }

    it "should call gather_google_contacts" do
      User.any_instance.should_receive(:gather_google_contacts).and_return(contact_response)
      post :google
    end

    it "should set @contacts to array" do
      post :google
      expect(assigns(:contacts)).to eq contact_response
    end

    it "should return contacts as json" do
      post :google
      expect(response.body).to eq contact_response.to_json
    end
  end

  describe "#invite" do
    before do
      UserMailer.stub_chain(:invitations, :deliver)
    end

    let(:invitations) { ["dan@chefsteps.com", "danahern@chefsteps.com", "dahern@chefsteps.com"] }

    it "should call UserMailer" do
      UserMailer.should_receive(:invitations)
      post :invite, email: invitations
    end

    it "should return status :success json" do
      post :invite, email: invitations
      expect(response.body).to eq "{\"status\":\"success\"}"
    end
  end
end
