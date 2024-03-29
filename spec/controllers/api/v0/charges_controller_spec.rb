describe Api::V0::ChargesController do
  include Docs::V0::Charges::Api

  context 'POST /create', :dox do

    include Docs::V0::Charges::Create
    it 'should error if not logged in' do
      post :create, params: {sku: ''}
      expect(response.status).to eq(401)
    end

    context 'logged in' do
      before :each do
        @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
        token = ActorAddress.create_for_user(@user, client_metadata: "create").current_token
        request.env['HTTP_AUTHORIZATION'] = token.to_jwt

        @premium = {sku: "cs10002", title: "Premium", price: 5000, msrp: "10000", tax_code: "ODD"}
        @circulator = {sku: "cs10001", title: "Circulator", price: 20000, msrp: "25000", 'premiumPrice' => 17000, tax_code: "TPP"}

        StripeOrder.stub(:stripe_products).and_return([@circulator, @premium])
        StripeOrder.any_instance.stub(:send_to_stripe).and_return(nil)

        @billing_address = {billing_name: 'Joe Example', billing_address_line1: '123 Any Place', billing_address_city: 'Seattle', billing_address_state: 'WA', billing_address_zip: '98101', billing_address_country: 'United States'}
        @shipping_address = {shipping_name: 'Joe Example', shipping_address_line1: '123 Any Place', shipping_address_city: 'Seattle', shipping_address_state: 'WA', shipping_address_zip: '98101', shipping_address_country: 'United States'}

      end

      describe 'POST #create' do
        include Docs::V0::Charges::Create
        it 'should error if purchasing anything other than premium membership' do
          post :create, params: {sku: '1000'}
          expect(response.status).to eq(500)
        end

        it 'should queue charge when called correctly' do
          Resque.should_receive(:enqueue).with(StripeChargeProcessor, 1)
          Resque.should_receive(:enqueue).with(UserSync, @user.id)
          post :create, params: {sku: @premium[:sku], stripeToken: 'xxx', price: '5000', gift: 'false'}.merge(@billing_address)
          expect(response.status).to eq(200)
        end

        it 'should set the utm params if the cookie is set' do
          request.cookies[:utm] = "{'utm_campaign': 'railstest'}"
          options = {sku: @circulator[:sku], stripeToken: 'xxx', price: '20000', gift: 'false'}.merge(@billing_address).merge(@shipping_address)
          post :create, params: options
          expect(response.status).to eq(200)
        end

        it 'should error if user is already premium' do
          @user.make_premium_member(10)
          post :create, params: {sku: @premium[:sku], stripeToken: 'xxx', price: '5000'}
          expect(response.status).to eq(500)
        end

        it "should create the stripe_order object and set the user to premium when ordering the circulator" do
          options = {sku: @circulator[:sku], stripeToken: 'xxx', price: '20000', gift: 'false'}.merge(@billing_address).merge(@shipping_address)
          post :create, params: options
          stripe_order = StripeOrder.last
          stripe_order.user_id.should == @user.id
          stripe_order.data.should include('billing_name'=> 'Joe Example', 'billing_address_line1'=> '123 Any Place', 'billing_address_city'=> 'Seattle', 'billing_address_state'=> 'WA', 'billing_address_zip'=> '98101', 'billing_address_country'=> 'United States')
          stripe_order.data.should include('shipping_name'=> 'Joe Example', 'shipping_address_line1'=> '123 Any Place', 'shipping_address_city'=> 'Seattle', 'shipping_address_state'=> 'WA', 'shipping_address_zip'=> '98101', 'shipping_address_country'=> 'United States')
          stripe_order.data.should include('price' => 20000, 'description' => 'Joule + ChefSteps Premium', 'premium_discount' => false, 'circulator_sale' => true, 'circulator_discount' => 3000)
        end

        it "should create the stripe_order object and set the user to premium when ordering the circulator" do
          @user = Fabricate(:user, email: 'joeexample@chefsteps.com', password: '123456', name: 'John Doe', premium_member: 'true')
          token = ActorAddress.create_for_user(@user, client_metadata: "create").current_token
          request.env['HTTP_AUTHORIZATION'] = token.to_jwt
          @user.premium_member.should == true

          options = {sku: @circulator[:sku], stripeToken: 'xxx', price: '17000', gift: 'false'}.merge(@billing_address).merge(@shipping_address)
          post :create, params: options
          expect(response.status).to eq(200)
          stripe_order = StripeOrder.last
          stripe_order.should_not be_blank
          stripe_order.user_id.should_not be blank?
          stripe_order.user_id.should == @user.id
          stripe_order.data.should include('billing_name'=> 'Joe Example', 'billing_address_line1'=> '123 Any Place', 'billing_address_city'=> 'Seattle', 'billing_address_state'=> 'WA', 'billing_address_zip'=> '98101', 'billing_address_country'=> 'United States')
          stripe_order.data.should include('shipping_name'=> 'Joe Example', 'shipping_address_line1'=> '123 Any Place', 'shipping_address_city'=> 'Seattle', 'shipping_address_state'=> 'WA', 'shipping_address_zip'=> '98101', 'shipping_address_country'=> 'United States')
          stripe_order.data.should include('price' => 17000, 'description' => 'Joule + Premium Discount', 'premium_discount' => true, 'circulator_sale' => true, 'circulator_discount' => 3000)
        end

        it "should create the stripe_order without the billing and shipping" do
          options = {sku: @premium[:sku], stripeToken: 'xxx', price: '5000', gift: 'false'}
          post :create, params: options
          expect(response.status).to eq(200)
          stripe_order = StripeOrder.last
          stripe_order.user_id.should == @user.id
          stripe_order.data.should_not include('billing_name'=> 'Joe Example', 'billing_address_line1'=> '123 Any Place', 'billing_address_city'=> 'Seattle', 'billing_address_state'=> 'WA', 'billing_address_zip'=> '98101', 'billing_address_country'=> 'United States')
          stripe_order.data.should_not include('shipping_name'=> 'Joe Example', 'shipping_address_line1'=> '123 Any Place', 'shipping_address_city'=> 'Seattle', 'shipping_address_state'=> 'WA', 'shipping_address_zip'=> '98101', 'shipping_address_country'=> 'United States')
          stripe_order.data.should include('price' => 5000, 'description' => 'ChefSteps Premium', 'premium_discount' => false, 'circulator_sale' => false, 'circulator_discount' => 3000)
        end

        it 'should let give premium as a gift even if you are already premium yourself' do
          @user.make_premium_member(11)
          post :create, params: {sku: @premium[:sku], stripeToken: 'xxx', price: '5000', gift: "true"}
          expect(response.status).to eq(200)
        end

        it 'should work when price is not greater' do
          post :create, params: {sku: @premium[:sku], stripeToken: 'xxx', price: '6000', gift: "true"}
          expect(response.status).to eq(200)
        end

        it 'should error out when price is greater' do
          post :create, params: {sku: @premium[:sku], stripeToken: 'xxx', price: '1000', gift: "true"}
          expect(response.status).to eq(500)
        end

        it 'should only let you buy the circulator cheap once' do
          @user = Fabricate(:user, email: 'sample_user@chefsteps.com', password: '123456', name: 'John Doe', premium_member: true, used_circulator_discount: true)
          token = ActorAddress.create_for_user(@user, client_metadata: "create").current_token
          request.env['HTTP_AUTHORIZATION'] = token.to_jwt
          @user.premium_member.should == true

          options = {sku: @circulator[:sku], stripeToken: 'xxx', price: '17000', gift: 'false'}.merge(@billing_address).merge(@shipping_address)
          post :create, params: options
          expect(response.status).to eq(500)
        end
      end

      describe 'PUT #redeem' do
        include Docs::V0::Charges::Redeem
        it 'should redeem a valid gift certificate' do
          gc = Fabricate :premium_gift_certificate
          User.any_instance.should_receive(:make_premium_member)
          put :redeem, params: {id: gc.token}
        end
      end
    end
  end
end
