describe Api::V0::Shopping::ProductGroupsController do

  ca_product_groups_data = {
    iso2: 'CA',
    currency: 'CAD',
    product_groups: {
      joule: {},
      big_clamp: {},
      premium: {},
    }
  }

  us_product_groups_data = {
    iso2: 'US',
    currency: 'USD',
    product_groups: {
      joule: {},
      big_clamp: {},
      premium: {},
    }
  }

  before :each do
    Rails.cache.clear()
    WebMock.stub_request(:get, 'https://spree-staging1.herokuapp.com/api/v1/cs_countries/US/cs_product_groups')
      .to_return(status: 200, body: us_product_groups_data.to_json, headers: {})

    WebMock.stub_request(:get, 'https://spree-staging1.herokuapp.com/api/v1/cs_countries/CA/cs_product_groups')
      .to_return(status: 200, body: ca_product_groups_data.to_json, headers: {})
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
