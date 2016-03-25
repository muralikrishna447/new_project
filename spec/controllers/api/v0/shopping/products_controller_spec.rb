
describe Api::V0::Shopping::ProductsController do
  before :each do

    @non_premium_user = Fabricate :user, name: 'Non Premium User', email: 'non_premium_user@chefsteps.com', role: 'user', premium_member: false
    @premium_user = Fabricate :user, name: 'Premium User', email: 'premium_user@chefsteps.com', role: 'user', premium_member: true, used_circulator_discount: false
    @premium_user_used_discount = Fabricate :user, name: 'Premium User Used Discount', email: 'premium_user_used_discount@chefsteps.com', role: 'user', premium_member: true, used_circulator_discount: true

    products_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('products').data)['products']
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/products.json/)
      .to_return(status: 200, body: products_data.to_json, headers: {})

    WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/count.json/)
      .to_return(status: 200, body: "2", headers: {})

    products_1_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('products').data)['products'][0]
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/123.json/).to_return(status: 200, body: products_1_data.to_json)

    products_2_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('products').data)['products'][1]
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/345.json/).to_return(status: 200, body: products_2_data.to_json)

    products_2_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('products').data)['products'][0]
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/567.json/).to_return(status: 200, body: products_2_data.to_json)

    products_1_metafields_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('products').data)['products'][0]['metafields']
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/123\/metafields.json/).to_return(status: 200, body: products_1_metafields_data.to_json)

    products_2_metafields_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('products').data)['products'][1]['metafields']
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/345\/metafields.json/).to_return(status: 200, body: products_2_metafields_data.to_json)

  end

  describe 'GET /products' do
    it "should respond with an array of products" do 
      get :index
      response.should be_success
      products = JSON.parse(response.body)
      products.length.should eq(3)
    end

    it "should respond with an array of products when a user is not premium" do
      sign_in @non_premium_user
      controller.request.env['HTTP_AUTHORIZATION'] = @non_premium_user.valid_website_auth_token.to_jwt
      get :index
      response.should be_success
      products = JSON.parse(response.body)
      products.length.should eq(3)
    end

    it "should respond with an array of products when a user is premium" do
      sign_in @premium_user
      controller.request.env['HTTP_AUTHORIZATION'] = @premium_user.valid_website_auth_token.to_jwt
      get :index
      response.should be_success
      products = JSON.parse(response.body)
      products.length.should eq(3)
    end
  end

  describe 'private methods' do
    before :each do
      @controller = Api::V0::Shopping::ProductsController.new
    end

    context 'get_product_discount' do
      it "should return a discount for a product" do
        product = ShopifyAPI::Product.find(123)
        product_discount = @controller.instance_eval { get_product_discount(product) }
        expect(product_discount).to eq(800)
      end
    end
  end

  describe 'GET /products/:sku' do

    it "should respond with a product when a sku is provided " do
      get :show, id: 'cs123'
      response.should be_success
      product = JSON.parse(response.body)
      product['title'].should eq('Product1')
    end

    it "should respond with the product price" do
      get :show, id: 'cs123'
      response.should be_success
      product = JSON.parse(response.body)
      expect(product.has_key?('price')).to eq(true)
    end

    it "should properly handle cases where a sku cannot be found" do
      get :show, id: 'csNoSku'
      response.should be_success
      responseBody = JSON.parse(response.body)
      responseBody['message'].should eq('No product found for sku.')
    end

    it "should show the correct price when user is not logged in" do
      get :show, id: 'cs123'
      response.should be_success
      product = JSON.parse(response.body)
      expect(product['price']).to eq(1099)
    end

    it "should show the correct price when user is not premium" do
      sign_in @non_premium_user
      controller.request.env['HTTP_AUTHORIZATION'] = @non_premium_user.valid_website_auth_token.to_jwt
      get :show, {id: 'cs123'}, {'HTTP_AUTHORIZATION' => @non_premium_user.valid_website_auth_token.to_jwt}
      response.should be_success
      product = JSON.parse(response.body)
      expect(product['price']).to eq(1099)
    end

    it "should show the correct price when user is premium" do
      sign_in @premium_user
      controller.request.env['HTTP_AUTHORIZATION'] = @premium_user.valid_website_auth_token.to_jwt
      get :show, {id: 'cs10001'}, {'HTTP_AUTHORIZATION' => @premium_user.valid_website_auth_token.to_jwt}
      response.should be_success
      product = JSON.parse(response.body)
      expect(product['price']).to eq(20500)
    end

    it "should show the correct price when user is premium and has already used the circulator discount" do
      sign_in @premium_user_used_discount
      controller.request.env['HTTP_AUTHORIZATION'] = @premium_user_used_discount.valid_website_auth_token.to_jwt
      get :show, {id: 'cs10001'}, {'HTTP_AUTHORIZATION' => @premium_user_used_discount.valid_website_auth_token.to_jwt}
      response.should be_success
      product = JSON.parse(response.body)
      expect(product['price']).to eq(22900)

    end

  end
end
