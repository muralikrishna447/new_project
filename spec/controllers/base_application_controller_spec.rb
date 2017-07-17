require 'spec_helper'

describe BaseApplicationController, type: :controller do
  controller do
    def show
      render text: "Fall through to standard render"
    end
  end

  describe 'cors' do
    before do
      @localhost_origin = 'http://localhost:4000'
      @localhost_host = 'localhost:3000'
      @prod_origin = "http://www.chefsteps.com"
      @prod_https_origin = "https://www.chefsteps.com"
      @prod_different_origin = "http://example.com"

      @prod_host = "www.chefsteps.com"
    end

    def should_have_no_cors_headers
      response['Access-Control-Allow-Origin'].should be_nil
      response['Access-Control-Allow-Methods'].should be_nil
      response['Access-Control-Allow-Headers'].should be_nil
      response['Access-Control-Max-Age'].should be_nil
      response['Access-Control-Allow-Credentials'].should be_nil
    end

    def should_have_cors_headers (host, include_credentials = false)
      response['Access-Control-Allow-Origin'].should == host
      response['Access-Control-Allow-Methods'].should == 'POST, GET, PUT, DELETE, OPTIONS'
      response['Access-Control-Allow-Headers'].should == '*, X-Requested-With, X-Prototype-Version, X-CSRF-Token, Content-Type, Authorization'
      response['Access-Control-Max-Age'].should == '1728000'
      if include_credentials
        response['Access-Control-Allow-Credentials'].should == 'true'
      else
        response['Access-Control-Allow-Credentials'].should_not == 'true'
      end
    end

    it 'should return no cors headers when origin not specifies' do
      request.env['host'] = @prod_host
      get :show, id: 1

      should_have_no_cors_headers
    end

    it 'should basic cors headers when origin is specified' do
      request.env['host'] = @prod_host
      request.env['origin'] = @prod_different_origin
      get :show, id: 1

      should_have_cors_headers(@prod_different_origin, false)
    end

    it 'should allow credentials for localhost testing' do
      request.env['host'] = @localhost_host
      request.env['origin'] = @localhost_origin
      get :show, id: 1

      should_have_cors_headers(@localhost_origin, true)
    end

    it 'should allow credentials with prod origin'  do
      request.env['host'] = @prod_host
      request.env['origin'] = @prod_origin
      get :show, id: 1

      should_have_cors_headers(@prod_origin, true)
    end

    it 'should handle bad origins gracefully' do |variable|
      request.env['host'] = @prod_host
      request.env['origin'] = "file://" # this was actually seen in prod
      get :show, id: 1
      should_have_no_cors_headers
    end

    it 'should handle a gibberish origins gracefully' do |variable|
      request.env['host'] = @prod_host
      request.env['origin'] = "sdfw54%&*"
      get :show, id: 1
      should_have_no_cors_headers
    end

    it 'should set the cs_geo cookie' do
      request.env['host'] = @prod_host
      request.env['origin'] = @prod_origin
      get :show, id: 1
      response.cookies['cs_geo'].should_not be_nil
    end

    it 'should set the cs_geo/country cookie value to US' do
      request.env['host'] = @prod_host
      request.env['origin'] = @prod_origin
      get :show, id: 1
      cs_geo = JSON.parse(response.cookies['cs_geo'])
      cs_geo['country'].should == 'US'
    end

  end
end
