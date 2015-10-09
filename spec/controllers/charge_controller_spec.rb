require 'spec_helper'

describe ChargesController do
  describe "#create" do

    let(:user) { Fabricate(:user, id: 29) }
    let(:assembly) { Fabricate(:assembly, price: 39, title: "Cooking For the Hirsute", assembly_type: "Course")}
    before do
      sign_in user
    end

    context "errors" do
      it 'errors appropriately on a bad assembly id' do
        controller.stub(:params) { {stripeToken: 'xxx', assembly_id: 1}  }
        post :create
        expect(response.status).to eq(422)
        JSON.parse(response.body)["errors"][0].should include("Assembly")
      end
    end

    # context 'Enrollment' do
    #   before do
    #     Stripe::Customer.stub(:create).and_return(Stripe::Customer.new)
    #     Stripe::Customer.any_instance.stub(:id).and_return('BARGLE')
    #     @double_loc = double(Object)
    #     @double_loc.stub(:state).and_return("NJ")
    #     Geokit::Geocoders::IpGeocoder.should_receive(:geocode).and_return(@double_loc)
    #   end

    #   it 'is created in a normal case' do
    #     Stripe::Charge.should_receive(:create)
    #     post :create, assembly_id: assembly.id, discounted_price: 39
    #     expect(Enrollment.count).to eq(1)
    #     expect(Event.count).to eq(1)
    #     expect(response.status).to eq(204)
    #   end

    #   it 'is not created if charge fails' do
    #     Stripe::Charge.should_receive(:create).and_raise(Stripe::StripeError)
    #     post :create, assembly_id: assembly.id, discounted_price: 39
    #     expect(Enrollment.count).to eq(0)
    #     expect(Event.count).to eq(0)
    #     expect(response.status).to eq(422)
    #   end
    # end

    context "purchase types" do
      before do
        GiftCertificate.stub(:collect_money).and_return(true)
        Enrollment.stub(:collect_money).and_return(true)
      end

      context "gift purchase" do
        let(:gift_info) { {"recipientEmail" => "test@example.com", "recipientName" => "Test User"}.to_json }
        subject { post :create, assembly_id: assembly.id, gift_info: gift_info, stripeToken: 'xxx' }
        it "should create a gift certificate" do
          expect{subject}.to change(GiftCertificate, :count).by(1)
        end

        it "should set @gift_cert to the gift certificate" do
          subject
          expect(assigns(:gift_cert)).to be_an_instance_of(GiftCertificate)
        end

        it "should call GiftCertificate.purchase" do
          GiftCertificate.should_receive(:purchase).and_call_original
          subject
        end

      end

      context "gift redemption" do
        let(:gift_certificate){ Fabricate(:gift_certificate)}
        let(:gift_certificate_params) { {"id" => gift_certificate.id}.to_json }
        subject { post :create, assembly_id: assembly.id, gift_certificate: gift_certificate_params }

        it "should create an enrollment" do
          expect{subject}.to change(Enrollment, :count).by(1)
        end

        it "should call GiftCertificate.redeem" do
          GiftCertificate.should_receive(:redeem).and_call_original
          subject
        end

        it "should set @enrollment to the enrollment record" do
          subject
          expect(assigns(:enrollment)).to be_an_instance_of(Enrollment)
        end

        it "should set the session gift_token to nil" do
          subject
          expect(session[:gift_token]).to be nil
        end
      end

      context "normal enrollment" do
        subject { post :create, assembly_id: assembly.id, discounted_price: 39}
        it "should Enrollment.call enroll_user_in_assembly" do
          Enrollment.should_receive(:enroll_user_in_assembly).and_call_original
          subject
        end

        it "should create an enrollment" do
          expect{subject}.to change(Enrollment, :count).by(1)
        end

        it "should set @enrollment" do
          subject
          expect(assigns(:enrollment)).to be_an_instance_of(Enrollment)
        end
      end

      # TIMDISCOUNT
      context "Tim Ferriss free enrollment" do
        subject { post :create, assembly_id: assembly.id, discounted_price: 0}

        it "should only allow one free enrollment to a paid class" do
          subject
          user.reload
          expect(user.timf_incentive_available).to be(false)
        end
      end
    end
  end
end
