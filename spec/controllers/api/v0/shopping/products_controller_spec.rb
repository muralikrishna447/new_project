
describe Api::V0::Shopping::ProductsController do
  before :each do
    products_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('products').data)['products']
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/products.json/)
      .to_return(status: 200, body: products_data.to_json, headers: {})

    WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/count.json/)
      .to_return(status: 200, body: "2", headers: {})

    products_1_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('products').data)['products'][0]
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/123.json/).to_return(status: 200, body: products_1_data.to_json)

    products_2_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('products').data)['products'][1]
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/345.json/).to_return(status: 200, body: products_2_data.to_json)

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
      products.length.should eq(2)
    end
  end

  describe 'private methods' do
    before :each do
      @controller = Api::V0::Shopping::ProductsController.new
    end

    context 'product_id_by_sku' do
      it "should return a product_id" do
        product_id_1 = @controller.instance_eval { product_id_by_sku('cs123') }
        product_id_1.should eq(123)
        product_id_2 = @controller.instance_eval { product_id_by_sku('cs345') }
        product_id_2.should eq(345)
      end

      it "should properly handle cases where a sku cannot be found" do
        no_product_id = @controller.instance_eval { product_id_by_sku('csNoSku')}
        no_product_id.should eq(nil)
      end
    end

    context 'get_product_metafield' do
      it "should return metafields for a product" do
        product = ShopifyAPI::Product.find(123)
        product_metafields = @controller.instance_eval { get_product_metafield(product, 'price', 'msrp') }
        expect(product_metafields).to eq(2000)
      end
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
  end
end
