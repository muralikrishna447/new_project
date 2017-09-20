def puts(value)
  raise 'you found a puts'
end

def p(value)
  raise 'you found a puts'
end


describe Api::V0::Shopping::ProductGroupsController do
  before :each do
    Rails.cache.clear()
    @non_premium_user = Fabricate :user, name: 'Non Premium User', email: 'non_premium_user@chefsteps.com', role: 'user', premium_member: false
    @premium_user = Fabricate :user, name: 'Premium User', email: 'premium_user@chefsteps.com', role: 'user', premium_member: true, used_circulator_discount: false
    @premium_user_used_discount = Fabricate :user, name: 'Premium User Used Discount', email: 'premium_user_used_discount@chefsteps.com', role: 'user', premium_member: true, used_circulator_discount: true

    product_groups_data = {}

    # WebMock.stub_request(:get, /test.myshopify.com\/admin\/product_groups.json/)
    #   .to_return(status: 200, body: product_groups_data.to_json, headers: {})
    #
    # WebMock.stub_request(:get, /test.myshopify.com\/admin\/product_groups\/count.json/)
    #   .to_return(status: 200, body: "2", headers: {})
    #
    # product_groups_1_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('product_groups').data)['product_groups'][0]
    # WebMock.stub_request(:get, /test.myshopify.com\/admin\/product_groups\/123.json/).to_return(status: 200, body: product_groups_1_data.to_json)
    #
    # product_groups_2_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('product_groups').data)['product_groups'][1]
    # WebMock.stub_request(:get, /test.myshopify.com\/admin\/product_groups\/345.json/).to_return(status: 200, body: product_groups_2_data.to_json)
    #
    # product_groups_3_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('product_groups').data)['product_groups'][2]
    # WebMock.stub_request(:get, /test.myshopify.com\/admin\/product_groups\/567.json/).to_return(status: 200, body: product_groups_3_data.to_json)
    #
    # product_groups_4_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('product_groups').data)['product_groups'][3]
    # WebMock.stub_request(:get, /test.myshopify.com\/admin\/product_groups\/789.json/).to_return(status: 200, body: product_groups_4_data.to_json)
    #
    # product_groups_1_metafields_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('product_groups').data)['product_groups'][0]['metafields']
    # WebMock.stub_request(:get, /test.myshopify.com\/admin\/product_groups\/123\/metafields.json/).to_return(status: 200, body: product_groups_1_metafields_data.to_json)
    #
    # product_groups_2_metafields_data = JSON.parse(ShopifyAPI::Mock::Fixture.find('product_groups').data)['product_groups'][1]['metafields']
    # WebMock.stub_request(:get, /test.myshopify.com\/admin\/product_groups\/345\/metafields.json/).to_return(status: 200, body: product_groups_2_metafields_data.to_json)
  end

  describe 'GET /product_groups' do
    it "US should respond with an array of product_groups" do
      get :index, :iso2 => 'US'
      response.should be_success
      product_groups = JSON.parse(response.body)
      product_groups['product_groups'].length.should eq(3)
      product_groups['currency'].should eq('USD')
      product_groups['iso2'].should eq('US')
    end

    it "CA should respond with an array of product_groups" do
      get :index, :iso2 => 'CA'
      response.should be_success
      product_groups = JSON.parse(response.body)
      product_groups['product_groups'].length.should eq(3)
      product_groups['currency'].should eq('CAD')
      product_groups['iso2'].should eq('CA')
    end

    it "should respond with an array of product_groups even if CsSpree API dies" do
      get :index
      response.should be_success
      product_groups = JSON.parse(response.body)
      product_groups['product_groups'].length.should eq(3)

      CsSpree.stub(:get_api).and_raise(StandardError.new('Failed to get product_groups'))

      Timecop.travel(Time.now + 2.minutes) do
        get :index
        response.should be_success
        product_groups = JSON.parse(response.body)
        product_groups['product_groups'].length.should eq(3)
      end
    end
  end
end
