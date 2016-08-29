describe Api::V0::Shopping::DiscountsController do
  before :each do
    discounts_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('discounts').data)['discounts']
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/discounts.json/)
      .to_return(status: 200, body: discounts_data.to_json, headers: {})
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/discounts\/random01.json/)
      .to_return(status: 404, body: {message: 'discount not found'}.to_json, headers: {})
  end

  describe 'private methods' do
    before :each do
      @controller = Api::V0::Shopping::DiscountsController.new
    end

    context 'valid?(discount)' do
      it "should return true for a valid discount" do
        discount = ShopifyAPI::Discount.find(101)
        is_valid = @controller.instance_eval { valid?(discount) }
        expect(is_valid).to be_true
      end

      it "should return false for a disabled discount" do
        discount = ShopifyAPI::Discount.find(102)
        is_valid = @controller.instance_eval { valid?(discount) }
        expect(is_valid).to be_false
      end

      it "should return false for an expired discount" do
        discount = ShopifyAPI::Discount.find(103)
        is_valid = @controller.instance_eval { valid?(discount) }
        expect(is_valid).to be_false
      end

      it "should return false for an expired discount" do
        discount = ShopifyAPI::Discount.find(104)
        is_valid = @controller.instance_eval { valid?(discount) }
        expect(is_valid).to be_true
      end
    end

  end

  describe 'GET /discounts/:id' do

    it "should return a discount" do
      get :show, id: '101'
      response.should be_success
      discount = JSON.parse(response.body)
      discount['code'].should eq('valid01')
      discount['status'].should eq('enabled')
      discount['value'].should eq('10.00')
      discount['valid'].should be_true
    end

    it "should return 404" do
      get :show, id: 'random01'
      response.should_not be_success
      response.status.should eq(404)
    end

  end
end
