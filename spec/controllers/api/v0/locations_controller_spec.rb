describe Api::V0::LocationsController do
  context 'GET /locations' do
    before :each do
      # We cache location data by IP, so clear this out between invocations
      Rails.cache.clear
    end

    def mock_geo_ip(type)
      case type
      when 'error', 'not_found'
        controller.stub(:get_location_from_mmdb).and_raise('error')
      when 'success'
        controller.stub(:get_location_from_mmdb).and_return({country: 'US', long_country: 'United States'})
      when 'registered'
          controller.stub(:get_location_from_mmdb).and_return({country: 'PT', long_country: 'Portugal'})
      end
    end

    it "geo error should respond with location data defaulted to US" do
      mock_geo_ip('error')
      get :index
      response.should be_success
      location = JSON.parse(response.body)
      location.should include('country' => 'US', 'latitude' => nil, 'longitude' => nil, 'city' => nil, 'state' => nil, 'zip' => nil)
    end

    it "should respond with blank and defaulted to US" do
      @request.env['REMOTE_ADDR'] = '1.2.3.4'
      mock_geo_ip('not_found')
      get :index
      response.should be_success
      location = JSON.parse(response.body)
      location.should include('country' => 'US', 'latitude' => nil, 'longitude' => nil, 'city' => nil, 'state' => nil, 'zip' => nil)
    end

    it "should respond with location data" do
      @request.env['REMOTE_ADDR'] = '1.2.3.4'
      mock_geo_ip('success')
      get :index
      response.should be_success
      location = JSON.parse(response.body)
      location.should include('country' => 'US', 'long_country' => 'United States')
    end

    it "should respond with location data when geocode only returns registered_country" do
      @request.env['REMOTE_ADDR'] = '1.2.3.4'
      mock_geo_ip('registered')
      get :index
      response.should be_success
      location = JSON.parse(response.body)
      location.should include('country' => 'PT', 'long_country' => 'Portugal')
    end
  end
end
