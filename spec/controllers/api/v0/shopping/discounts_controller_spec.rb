describe Api::V0::Shopping::DiscountsController do
  before :each do
    discounts_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('discounts').data)['discounts']
    WebMock.stub_request(:get, /test.myshopify.com\/admin\/discounts.json/)
      .to_return(status: 200, body: discounts_data.to_json, headers: {})
  end

  describe 'private methods' do
    before :each do
      @controller = Api::V0::Shopping::DiscountsController.new
    end

    context 'get_all_discounts' do
      it "should return an array of all discounts" do
        discounts = @controller.instance_eval { get_all_discounts }
        expect(discounts.length).to eq(4)
      end
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

    context 'map_valid' do
      it "should return an array of discounts and set the valid attribute" do
        discounts = @controller.instance_eval { map_valid }
        puts "discounts here: #{discounts.inspect}"
        expect(discounts.length).to eq(4)
        expect(discounts.map{|d| d.valid}).to eq([true,false,false,true])
      end
    end
  end

  describe 'GET /discounts/:code' do

    it "should return a discount" do
      get :show, id: 'valid01'
      response.should be_success
      discount = JSON.parse(response.body)
      discount['status'].should eq('enabled')
      discount['value'].should eq('10.00')
      discount['valid'].should be_true
    end

  end
end
