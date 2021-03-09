describe Api::V0::LocationsController do
  include Docs::V0::Locations::Api

  describe 'GET #index' do
    include Docs::V0::Locations::Index
    context 'GET /locations', :dox do

      let(:default_result) { { country: 'US', long_country: 'United States' } }
      let(:registered_result) { { country: 'PT', long_country: 'Portugal' } }

      def mock_geo_ip(type)
        case type
        when 'error'
          allow(GeoipService).to receive(:get_geocode).and_raise('error')
        when 'not_found'
          allow(GeoipService).to receive(:get_geocode).and_raise(GeoipService::GeocodeError)
        when 'success'
          allow(GeoipService).to receive(:get_geocode).and_return(default_result)
        when 'registered'
          allow(GeoipService).to receive(:get_geocode).and_return(registered_result)
        end
      end

      it "geo error should respond with location data defaulted to US" do
        mock_geo_ip('error')
        get :index
        response.should be_success
        location = JSON.parse(response.body)
        location.should include('country' => 'US', 'long_country' => nil)
      end

      it "should respond with blank and defaulted to US" do
        @request.env['REMOTE_ADDR'] = '1.2.3.4'
        mock_geo_ip('not_found')
        get :index
        response.should be_success
        location = JSON.parse(response.body)
        location.should include('country' => 'US', 'long_country' => nil)
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
end
