require 'spec_helper'

describe ChargesController, "#create" do

  context 'user is authenticated' do
    let(:user) { Fabricate(:user, id: 29) }
    let(:assembly) { Fabricate(:assembly, id: 37, price: 39, title: "Cooking For the Hirsute")}
    before do
      sign_in user
    end

    it 'errors appropriately on a bad assembly id' do
      controller.stub(:params) { {stripeToken: 'xxx', assembly_id: 1}  }
      post :create
      expect(response.status).to eq(422)
      JSON.parse(response.body)["errors"][0].should include("Assembly")
    end

    context 'Enrollment' do
      before do
        Stripe::Customer.stub(:create).and_return(Stripe::Customer.new)
        Stripe::Customer.any_instance.stub(:id).and_return('BARGLE')
        assembly.save!
        @double_loc = double(Object)
        @double_loc.stub(:state).and_return("NJ")
        Geokit::Geocoders::IpGeocoder.should_receive(:geocode).and_return(@double_loc)
     end

      it 'is created in a normal case' do
        Stripe::Charge.should_receive(:create)
        post :create, assembly_id: 37, discounted_price: 39
        expect(Enrollment.count).to eq(1)
        expect(Event.count).to eq(1)
        expect(response.status).to eq(204)
      end

      it 'is not created if charge fails' do
        Stripe::Charge.should_receive(:create).and_raise(Stripe::StripeError)
        post :create, assembly_id: 37, discounted_price: 39
        expect(Enrollment.count).to eq(0)
        expect(Event.count).to eq(0)
        expect(response.status).to eq(422)
      end
    end
  end
end
