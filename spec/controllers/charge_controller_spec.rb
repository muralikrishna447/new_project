require 'spec_helper'

describe ChargesController, "#create" do

  context 'user is authenticated' do
    let(:user) { Fabricate(:user, id: 29) }
    let(:assembly) { stub('assembly', id: 37, price: 10.99, title: "Cooking For the Hirsute")}
    before do
      sign_in user
    end

    it 'errors appropriately on a bad assembly id' do
      controller.stub(:params) { {stripeToken: 'xxx', assembly_id: 1}  }
      post :create
      expect(response.status).to eq(422)
      JSON.parse(response.body)["errors"][0].should include("Assembly")
    end

    context 'ip based tax calculations', focus: true do

      before do
        Assembly.stub(:find).and_return(assembly)
        Stripe::Customer.stub(:create).and_return(Stripe::Customer.new)
        Stripe::Customer.any_instance.stub(:id).and_return('BARGLE')
        Stripe::Customer.should_receive(:create)
        @double_enrollment = double(Enrollment)
        @double_enrollment.stub(:save!)
      end        

      it 'stores correct price and tax in enrollment in a no tax situation' do
        Enrollment.should_receive(:new).with(hash_including({price: 10.99, sales_tax: 0})).and_return(@double_enrollment)
        Stripe::Charge.should_receive(:create).with(hash_including({description: "Cooking For the Hirsute"}))
        post :create, assembly_id: 37
      end

      it 'stores correct price and tax in enrollment in a taxed situation' do
        request.stub(:remote_ip).and_return("216.186.5.154")
        Enrollment.should_receive(:new).with(hash_including({price: 10.04, sales_tax: 0.95})).and_return(@double_enrollment)
        Stripe::Charge.should_receive(:create).with(hash_including({description: "Cooking For the Hirsute (including $0.95 WA state sales tax)"}))
        post :create, assembly_id: 37
      end
   end

 
    # This is no good, it is hitting the server. Need to mock the Stripe apis, and not super
    # sure how to go about that. Seems like I should be able to use the ones in stripe_ruby or possibly
    # rspec_stripe but not finding any examples.
    # Using integration tests instead, see charged_courses_spec.rb.
=begin
    it 'errors appropriately on bad stripe token' do    
      Assembly.stub(:find).with(37).and_return(assembly)
      controller.stub(:params) { {stripeToken: 'tok_1SvcpNfP8fC0f6', assembly_id: assembly.id}  }
       post :create
      puts response.body
      expect(response.status).to eq(422)
      JSON.parse(response.body)["errors"][0].should include("Invalid token")
    end
=end
  end

  context 'basic sales tax computation' do   
    it 'computes correct tax for various IP addresses' do
      @controller = ChargesController.new
      # localhost
      expect(@controller.instance_eval{adjust_for_included_tax(100, "127.0.0.1")}).to eq([100,0])
      # new jersey
      expect(@controller.instance_eval{adjust_for_included_tax(100, "199.231.185.97")}).to eq([100, 0])
      # richland, WA
      expect(@controller.instance_eval{adjust_for_included_tax(100, "216.186.5.154")}).to eq([91.32, 8.68])
    end
  end

end
