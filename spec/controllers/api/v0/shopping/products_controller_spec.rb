
describe Api::V0::Shopping::ProductsController do
  before :each do
    Rails.cache.clear()
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

    products_3_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('products').data)['products'][2]
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/567.json/).to_return(status: 200, body: products_3_data.to_json)

    products_4_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('products').data)['products'][3]
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/789.json/).to_return(status: 200, body: products_4_data.to_json)

    products_1_metafields_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('products').data)['products'][0]['metafields']
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/123\/metafields.json/).to_return(status: 200, body: products_1_metafields_data.to_json)

    products_2_metafields_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('products').data)['products'][1]['metafields']
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/345\/metafields.json/).to_return(status: 200, body: products_2_metafields_data.to_json)

  end

  #skipping per Shopify removal
  describe 'GET /products', :skip => 'true' do
    it "should respond with an array of products" do
      get :index
      response.should be_success
      products = JSON.parse(response.body)
      products.length.should eq(4)
    end

    it "should respond with an array of products even if shopify Product API dies" do
      get :index
      response.should be_success
      products = JSON.parse(response.body)
      products.length.should eq(4)

      ShopifyAPI::Product.stub(:all) \
        .and_raise(StandardError.new('uh oh we failed to get products'))

      Timecop.travel(Time.now + 2.minutes) do
        get :index
        response.should be_success
        products = JSON.parse(response.body)
        products.length.should eq(4)
      end
    end

    it "should respond with an array of products even if shopify Product count API dies" do
      get :index
      response.should be_success
      products = JSON.parse(response.body)
      products.length.should eq(4)

      ShopifyAPI::Product.stub(:count) \
        .and_raise(StandardError.new('uh oh we failed to get product count'))

      Timecop.travel(Time.now + 2.minutes) do
        get :index
        response.should be_success
        products = JSON.parse(response.body)
        products.length.should eq(4)
      end
    end
  end

  describe 'private methods' do
    before :each do
      @controller = Api::V0::Shopping::ProductsController.new
    end

    context 'get_product_sku' do
      it 'should return the product sku' do
        sku = 'cs10001-hello'
        product_sku = @controller.instance_eval { get_product_sku(sku) }
        expect(product_sku).to eq('cs10001')
      end
    end

    context 'get_variants' do
      it 'should return the product sku' do
        product = ShopifyAPI::Product.find(789)
        variants = @controller.instance_eval { get_variants(product) }
        expect(variants.length).to eq(3)
      end
    end

  end

  #skipping per Shopify removal
  describe 'GET /products/:sku', :skip => 'true' do

    it "should respond with a product when a sku is provided " do
      get :show, id: 'cs123'
      response.should be_success
      # product = JSON.parse(response.body)
      # product['title'].should eq('Product1')
    end

    it "should properly handle cases where a sku cannot be found" do
      get :show, id: 'csNoSku'
      response.should be_success
      responseBody = JSON.parse(response.body)
      responseBody['message'].should eq('No product found for sku.')
    end

  end
end
