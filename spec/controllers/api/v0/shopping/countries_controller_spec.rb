describe Api::V0::Shopping::CountriesController do


  context 'with failing intl_enabled API requests' do
    before :each do
      Rails.cache.clear()
      WebMock.stub_request(:get, 'https://spree-staging1.herokuapp.com/api/v1/cs_countries/intl_enabled')
        .to_return(status: 500, body: "Internal Server Error")

      WebMock.stub_request(:get, 'https://spree-staging1.herokuapp.com/api/v1/cs_countries/enabled_countries')
        .to_return(status: 200, body: {countries: ["US", "CA", "IT"]}.to_json, headers: {})
    end

    it "Should respond with ERROR" do
      get :index
      response.should_not be_success
    end

  end

  context 'with failing enabled countries API requests' do
    before :each do
      Rails.cache.clear()
      WebMock.stub_request(:get, 'https://spree-staging1.herokuapp.com/api/v1/cs_countries/intl_enabled')
        .to_return(status: 200, body: {intl_enabled: true}.to_json, headers: {})

      WebMock.stub_request(:get, 'https://spree-staging1.herokuapp.com/api/v1/cs_countries/enabled_countries')
        .to_return(status: 400, body: "Bad Request")
    end

    it "Should respond with ERROR" do
      get :index
      response.should_not be_success
    end

  end


  context 'working spree api' do

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
end
