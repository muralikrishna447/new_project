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
end
