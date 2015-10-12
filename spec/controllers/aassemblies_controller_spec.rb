require 'spec_helper'

describe AssembliesController do
  before(:each) do
    @purchaser = Fabricate(:user, name: "Purchaser", email: "test@chefsteps.com")
    @assembly = Fabricate(:assembly, price: 39.00, assembly_type: "Course", published: true)
  end

  describe 'redeem' do

    context "invalid token" do
      it "should redirect" do
        get :redeem, gift_token: "madeup"
        expect(response).to be_redirect
      end
      it "should set flash" do
        expect{get :redeem, gift_token: "madeup"}.to change{flash[:error]}.to("Invalid gift code. Contact <a href='mailto:info@chefsteps.com'>info@chefsteps.com</a>.")
      end
    end

    context "valid gift certificate" do
      before(:each) do
        @gift_certificate = Fabricate(:gift_certificate, token: "normal", assembly_id: @assembly.id, redeemed: false, purchaser_id: @purchaser.id, recipient_email: "danahern@chefsteps.com", recipient_name: "Dan Ahern Recipient", recipient_message: "Enjoy", price: 0, redeemed: false)
        get :redeem, gift_token: "normal"
      end

      it "should set @gift_certifiate" do
        assigns(:gift_certificate).should eq @gift_certificate
      end

      it "should set @assembly" do
        assigns(:assembly).should eq @assembly
      end
    end


    context "unredeemed gift certificates" do
      before(:each) do
        @redeemable_certificate = Fabricate(:gift_certificate, token: "redeem", assembly_id: @assembly.id, redeemed: false, purchaser_id: @purchaser.id, recipient_email: "danahern@chefsteps.com", recipient_name: "Dan Ahern Recipient", recipient_message: "Enjoy", price: 0, redeemed: false)
      end

      it "should redirect to the landing_class_url" do
        get :redeem, gift_token: "redeem"
        expect(response).to be_redirect
        response.should redirect_to(landing_class_url(@assembly))
      end

      it "should set the flash notice" do
        expect{get :redeem, gift_token: "redeem"}.to change{flash[:notice]}.to("To get your gift, click the orange button below!")
      end
    end

    context "redeemed gift certificates" do
      before(:each) do
        @redeemed_certificate = Fabricate(:gift_certificate, token: "used", assembly_id: @assembly.id, redeemed: false, purchaser_id: @purchaser.id, recipient_email: "danahern@chefsteps.com", recipient_name: "Dan Ahern Recipient", recipient_message: "Enjoy", price: 0, redeemed: true)
      end
      context "not signed in" do
        it "should redirect to the sign_in_url" do
          get :redeem, gift_token: "used"
          expect(response).to be_redirect
          response.should redirect_to(sign_in_url)
        end

        it "should set the flash notice" do
          expect{get :redeem, gift_token: "used"}.to change{flash[:notice]}.to("Gift code already used; please sign in to continue your class. If you need assistance, contact <a href='mailto:info@chefsteps.com'>info@chefsteps.com</a>.")
        end

        it "should set the session force_return_to" do
          expect{get :redeem, gift_token: "used"}.to change{session[:force_return_to]}.to(request.original_url)
        end
      end

      context "signed in" do
        before(:each) do
          @receiver = Fabricate(:user, name: "Receiver", email: "danahern@chefsteps.com")
          sign_in @receiver
        end

        it "should redirect to the sign_in_url" do
          get :redeem, gift_token: "used"
          expect(response).to be_redirect
          response.should redirect_to(landing_class_url(@assembly))
        end

        it "should set the flash notice" do
          expect{get :redeem, gift_token: "used"}.to change{flash[:notice]}.to("Gift code already used; click the orange button below to continue your class. If you need assistance, contact <a href='mailto:info@chefsteps.com'>info@chefsteps.com</a>.")
        end
      end
    end
  end
end