require 'spec_helper'

describe ChargesController, "#create" do

  context 'user is authenticated' do
    let(:user) { Fabricate(:user, id: 29) }
    let(:assembly) { stub('assembly', id: 37, price: "10.99", title: "Cooking For the Hirsute")}
 
    before do
      sign_in user
    end

    it 'errors appropriately on a bad assembly id' do
      controller.stub(:params) { {stripeToken: 'xxx', assembly_id: 1}  }
      post :create
      expect(response.status).to eq(422)
      JSON.parse(response.body)["errors"][0].should include("Assembly")
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
end
