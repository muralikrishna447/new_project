describe Api::V0::ShoppingController do
  before :each do
    ShopifyAPI::Base.stub(:site).and_return(URI.parse('https://test.myshopify.com/admin'))
    ShopifyAPI::Product.stub(:get).and_return({"id"=>1538566017, "title"=>"Ribeye Special", "body_html"=>"Such tasty meat.. I can't even believe it", "vendor"=>"ChefSteps.com", "product_type"=>"", "created_at"=>"2015-07-15T16:52:12-04:00", "handle"=>"ribeye-special", "updated_at"=>"2015-07-23T12:23:28-04:00", "published_at"=>"2015-07-23T01:43:00-04:00", "template_suffix"=>nil, "published_scope"=>"global", "tags"=>"", "variants"=>[{"id"=>4652374913, "product_id"=>1538566017, "title"=>"Default Title", "price"=>"120.00", "sku"=>"", "position"=>1, "grams"=>0, "inventory_policy"=>"deny", "compare_at_price"=>nil, "fulfillment_service"=>"manual", "inventory_management"=>"shopify", "option1"=>"Default Title", "option2"=>nil, "option3"=>nil, "created_at"=>"2015-07-15T16:52:12-04:00", "updated_at"=>"2015-07-23T12:23:28-04:00", "requires_shipping"=>true, "taxable"=>true, "barcode"=>"", "inventory_quantity"=>2, "old_inventory_quantity"=>2, "image_id"=>nil, "weight"=>0.0, "weight_unit"=>"lb"}], "options"=>[{"id"=>1816004609, "product_id"=>1538566017, "name"=>"Title", "position"=>1, "values"=>["Default Title"]}], "images"=>[{"id"=>3589478849, "product_id"=>1538566017, "position"=>1, "created_at"=>"2015-07-15T16:52:13-04:00", "updated_at"=>"2015-07-15T16:52:13-04:00", "src"=>"https://cdn.shopify.com/s/files/1/0171/7850/products/ribeye.jpg?v=1436993533", "variant_ids"=>[]}], "image"=>{"id"=>3589478849, "product_id"=>1538566017, "position"=>1, "created_at"=>"2015-07-15T16:52:13-04:00", "updated_at"=>"2015-07-15T16:52:13-04:00", "src"=>"https://cdn.shopify.com/s/files/1/0171/7850/products/ribeye.jpg?v=1436993533", "variant_ids"=>[]}})
    ShopifyMultipass.any_instance.stub(:generate_token).and_return('abc123')
  end

  context 'GET /product' do
    it "should respond with a json object with an id and quantity" do
      get :product
      response.should be_success
      product = JSON.parse(response.body)
      product['quantity'].should == 2
      product['id'].should == 1538566017
    end
  end

  context 'GET /multipass' do
    before :each do
      @user = Fabricate :user, email: "test@example.com", name: "Tester Example"
      sign_in @user
    end

    describe 'autoredirect' do
      it 'should redirect to multipass' do
        get :multipass, {product_id: 123, quantity: 1, autoredirect: true}
        response.should redirect_to("https://test.myshopify.com/account/login/multipass/abc123")
      end

    end
    describe 'ajax request' do
      it "should return a json with multipass" do
        get :multipass, {product_id: 123, quantity: 1}
        redirect = JSON.parse(response.body)
        redirect['redirect_to'].should == "https://test.myshopify.com/account/login/multipass/abc123"
      end
    end
  end

end
