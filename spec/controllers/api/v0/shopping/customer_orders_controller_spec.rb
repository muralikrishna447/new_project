describe Api::V0::Shopping::CustomerOrdersController do
  before :each do

    @user = Fabricate :user, id: 10001, name: 'customer_1', email: 'customer_1@chefsteps.com', role: 'user'
    @admin = Fabricate :user, id: 10002, name: 'admin_1', email: 'admin@chefsteps.com', role: 'admin'


    customer_order_101_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('customer_order_101').data)['order']
    customer_order_202_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('customer_order_202').data)['order']

    WebMock.stub_request(:get, /test.myshopify.com\/admin\/orders\/101.json/)
      .to_return(status: 200, body: customer_order_101_data.to_json, headers: {})
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/orders\/202.json/)
      .to_return(status: 200, body: customer_order_202_data.to_json, headers: {})
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/orders\/random01.json/)
      .to_return(status: 404, body: {message: 'customer_order not found'}.to_json, headers: {})
  end

  describe 'GET /customer_orders/:id' do

    it "should return a customer_order" do
      sign_in @user
      controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
      get :show, id: '101'
      response.should be_success
      customer_order = JSON.parse(response.body)
      customer_order['id'].should eq(101)
    end


    it "should return 404 when order does not exist" do
      sign_in @user
      controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
      get :show, id: 'random01'
      response.should_not be_success
      response.status.should eq(404)
    end

    it "should return 404 when order does not belong to user" do
      sign_in @user
      controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
      get :show, id: '202'
      response.should_not be_success
      response.status.should eq(403)
    end

    it "should return a customer_order if user is admin" do
      sign_in @admin
      controller.request.env['HTTP_AUTHORIZATION'] = @admin.valid_website_auth_token.to_jwt
      get :show, id: '101'
      response.should be_success
      customer_order = JSON.parse(response.body)
      customer_order['id'].should eq(101)
    end

  end

  describe 'POST /customer_orders/:id/update_address' do
    it "should update an address" do
      sign_in @user
      controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
      order_params = {
        shipping_address: {
          address1: '123 random street',
          address2: '',
          city: 'Seattle',
          province: 'WA',
          zip: '12345'
        }
      }
      post :update_address, id: '101', order: order_params
      response.should be_success
    end

    it "should not update an address if the user is not signed in" do
      order_params = {
        shipping_address: {
          address1: '123 random street',
          address2: '',
          city: 'Seattle',
          province: 'WA',
          zip: '12345'
        }
      }
      post :update_address, id: '101', order: order_params
      response.should_not be_success
      response.status.should eq(403)
    end

    it "should not update an address if the address is invalid" do
      sign_in @user
      controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
      order_params = {
        shipping_address: {
          address1: '',
          address2: '',
          city: 'Seattle',
          province: 'WA',
          zip: '12345'
        }
      }
      post :update_address, id: '101', order: order_params
      response.should_not be_success
      response.status.should eq(400)
      address = JSON.parse(response.body)
      address['errors'][0].should eq("address1 can't be blank")
    end
  end

  describe 'POST /customer_orders/:id/confirm_address' do
    it "should confirm an address" do
      post :confirm_address, id: '101'
      response.should be_success
    end
  end
end
