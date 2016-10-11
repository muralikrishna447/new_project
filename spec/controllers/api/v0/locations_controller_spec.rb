describe Api::V0::LocationsController do
  context 'GET /locations' do
    def mock_geo(resp)
      WebMock.stub_request(:get, /.*geoip.maxmind.com\/geoip\/v2.1\/city.*/) \
        .to_return(:status => 200, :body => JSON.generate(resp), :headers => {})
    end
    it "geo error should respond with blank location data" do
      mock_geo({'error' => 'bleh'})
      get :index
      response.should be_success
      location = JSON.parse(response.body)
      location.should include('country' => nil, 'latitude' => nil, 'longitude' => nil, 'city' => nil, 'state' => nil, 'zip' => nil, 'taxPercent' => nil)
    end

    it "should respond with blank" do
      @request.env['REMOTE_ADDR'] = '1.2.3.4'
      mock_geo(Hashie::Mash.new(location: {latitude: 47.5943, longitude: -122.6265}, city: {names: {en: 'Bremerton'}}, subdivisions: [{iso_code: 'WA'}], postal: {code: '98310'}))
      get :index
      response.should be_success
      location = JSON.parse(response.body)
      location.should include('country' => nil, 'latitude' => nil, 'longitude' => nil, 'city' => nil, 'state' => nil, 'zip' => nil, 'taxPercent' => nil)
    end

    it "should respond with location data" do
      @request.env['REMOTE_ADDR'] = '1.2.3.4'
      mock_geo(Hashie::Mash.new(country: {iso_code: 'US'}, location: {latitude: 47.5943, longitude: -122.6265}, city: {names: {en: 'Bremerton'}}, subdivisions: [{iso_code: 'WA'}], postal: {code: '98310'}))
      AvaTax::TaxService.any_instance.stub(:estimate).and_return('Rate' => '0.084')
      get :index
      response.should be_success
      location = JSON.parse(response.body)
      location.should include('country' => 'US', 'latitude' => 47.5943, 'longitude' => -122.6265, 'city' => 'Bremerton', 'state' => 'WA', 'zip' => '98310', 'taxPercent' => '0.084')
    end
  end
end
