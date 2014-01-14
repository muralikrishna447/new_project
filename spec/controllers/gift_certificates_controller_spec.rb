require 'spec_helper'

describe GiftCertificatesController do
  describe 'index' do
    let(:admin){ Fabricate(:user, name: "Admin", email: "admin@chefsteps.com", role: "admin") }

    it 'should allow an admin to view' do
      sign_in admin
      get :index
      expect(response).to be_success
    end

    it "should raise an error if non-admin tries to view" do
      expect { get :index }.to raise_error(CanCan::AccessDenied)
    end

    context "json" do
      before(:each) do
        @purchaser = Fabricate(:user, name: "Purchaser", email: "test@chefsteps.com")
        @assembly = Fabricate(:assembly, price: 39.00, assembly_type: "Course")
        @gift_certificate = Fabricate(:gift_certificate, assembly_id: @assembly.id, redeemed: false, purchaser_id: @purchaser.id, recipient_email: "danahern@chefsteps.com", recipient_name: "Dan Ahern Recipient", recipient_message: "Enjoy", price: 0)
        @gift_certificate_2 = Fabricate(:gift_certificate, assembly_id: @assembly.id, redeemed: false, purchaser_id: @purchaser.id, recipient_email: "dan@chefsteps.com", recipient_name: "Dan Ahern Secondary", recipient_message: "Enjoy this secondary present", price: 39.00)
      end

      subject do
        sign_in admin
        get :index, format: :json
        parsed_body = JSON.parse(response.body)
      end

      context "no scopes" do
        subject do
          sign_in admin
          get :index, format: :json
          parsed_body = JSON.parse(response.body)
        end

        its(:count){ should == 2}
        it{ subject.first["id"].should eq @gift_certificate.id }
        it{ subject.first["user"]["id"].should eq @purchaser.id }
        it{ subject.first["assembly"]["id"].should eq @assembly.id }

        it "should set the gift_certificates" do
          sign_in admin
          get :index, format: :json
          expect(assigns(:gift_certificates)).to eq GiftCertificate.all
        end
      end

      context "free gift certificates" do
        subject do
          sign_in admin
          get :index, free_gifts: "true", format: :json
          parsed_body = JSON.parse(response.body)
        end

        its(:count){ should == 1}
        it{ subject.first["id"].should eq @gift_certificate.id }
        it{ subject.first["user"]["id"].should eq @purchaser.id }
        it{ subject.first["assembly"]["id"].should eq @assembly.id }

        it "should set the gift_certificates" do
          sign_in admin
          get :index, free_gifts: "true", format: :json
          expect(assigns(:gift_certificates)).to eq GiftCertificate.free_gifts
        end
      end
    end

  end
end