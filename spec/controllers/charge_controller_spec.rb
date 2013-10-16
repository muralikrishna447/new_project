require 'spec_helper'

describe ChargesController, "#create" do

  context 'user is authenticated' do
    let(:user) { Fabricate(:user, id: 29) }
    let(:assembly) { stub('assembly', id: 37, price: 39, title: "Cooking For the Hirsute")}
    before do
      sign_in user
    end

    it 'errors appropriately on a bad assembly id' do
      controller.stub(:params) { {stripeToken: 'xxx', assembly_id: 1}  }
      post :create
      expect(response.status).to eq(422)
      JSON.parse(response.body)["errors"][0].should include("Assembly")
    end

    context 'ip based tax calculations' do

      before do
        Assembly.stub(:find).and_return(assembly)
        Stripe::Customer.stub(:create).and_return(Stripe::Customer.new)
        Stripe::Customer.any_instance.stub(:id).and_return('BARGLE')
        Stripe::Customer.should_receive(:create)
        @double_enrollment = double(Enrollment)
        @double_enrollment.stub(:save!)
        @double_loc = double(Object)
      end        

      it 'stores correct price and tax in enrollment in a no tax situation' do
        @double_loc.stub(:state).and_return("NJ")
        Geokit::Geocoders::IpGeocoder.should_receive(:geocode).and_return(@double_loc)
        Stripe::Charge.should_receive(:create).with(hash_including({description: "Cooking For the Hirsute"}))
        post :create, assembly_id: 37, discounted_price: 39
      end

      it 'stores correct price and tax in enrollment in a taxed situation' do        
        @double_loc.stub(:state).and_return("WA")
        Geokit::Geocoders::IpGeocoder.should_receive(:geocode).and_return(@double_loc)
        Enrollment.should_receive(:new).with(hash_including({price: 35.62, sales_tax: 3.38})).and_return(@double_enrollment)
        Stripe::Charge.should_receive(:create).with(hash_including({description: "Cooking For the Hirsute (including $3.38 WA state sales tax)"}))
        post :create, assembly_id: 37, discounted_price: 39
      end
    end
  end
end
