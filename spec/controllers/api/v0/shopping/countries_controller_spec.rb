describe Api::V0::Shopping::CountriesController do


  before :each do
    Rails.cache.clear()
    WebMock.stub_request(:get, 'https://spree-staging1.herokuapp.com/api/v1/cs_countries/intl_enabled')
        .to_return(status: 200, body: {intl_enabled: true}.to_json, headers: {})

    WebMock.stub_request(:get, 'https://spree-staging1.herokuapp.com/api/v1/cs_countries/enabled_countries')
        .to_return(status: 200, body: {countries: ["US", "CA", "IT"]}.to_json, headers: {})
  end



  describe 'GET /intl_enabled and /enabled_countries' do
    it "should respond with intl_enabled boolean" do
      get :index
      response.should be_success
      resp = JSON.parse(response.body)
      resp["intl_enabled"].should eq(true)
      resp["countries"].should eq(["US", "CA", "IT"])
    end
  end
end
