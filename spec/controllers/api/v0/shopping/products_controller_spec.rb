describe Api::V0::Shopping::ProductsController do
  before :each do
    # Toggle enabled to force reload of fixtures
    ShopifyAPI::Mock.enabled = false
    ShopifyAPI::Mock.enabled = true
    puts "PRODUCTS ARE HERE: #{ShopifyAPI::Mock::Fixture.all.inspect}"
    # products_data = [JSON.parse(ShopifyAPI::Mock::Fixture.find('products').data)['products']]
    # puts "products_data: #{products_data}"
    # WebMock.stub_request(:get, /test.myshopify.com\/admin\/products.json/)
    #   .to_return(status: 200, body: products_data.to_json, headers: {})


    # products_response = [
    #   {
    #     id: 123,
    #     title: 'Product1',
    #     variants: [
    #       {
    #         sku: 'cs123'
    #       }
    #     ]
    #   },
    #   {
    #     id: 345,
    #     title: 'Product2',
    #     sku: 'cs345',
    #     variants: [
    #       {
    #         sku: 'cs345'
    #       }
    #     ]
    #   }
    # ]
    # WebMock.stub_request(:get, /test.myshopify.com\/admin\/products.json/).to_return(status: 200, body: products_response.to_json)
    #
    # product_1_response = {
    #   title: 'Product1',
    #   id: 345,
    #   tags: 'premium-discount:800',
    #   metafields: [
    #
    #   ],
    #   variants: [
    #     {
    #       sku: 'cs123',
    #       price: '10.00'
    #     }
    #   ]
    # }
    #
    # WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/123.json/).to_return(status: 200, body: product_1_response.to_json)
    #
    # product_1_metafields_response = {
    #   metafields: [
    #     {
    #       namespace: 'price',
    #       key: 'msrp',
    #       value: 2000
    #     }
    #   ]
    # }
    #
    # WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/345\/metafields.json/).to_return(status: 200, body: product_1_metafields_response.to_json)
    #
    # product_2_metafields_response = {
    #   metafields: [
    #     {
    #       namespace: 'price',
    #       key: 'msrp',
    #       value: 2000
    #     }
    #   ]
    # }
    #
    # WebMock.stub_request(:get, /test.myshopify.com\/admin\/products\/345\/metafields.json/).to_return(status: 200, body: product_2_metafields_response.to_json)
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
