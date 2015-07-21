require 'spec_helper'

describe ApplicationController, type: :controller do
  describe "API serves global navigation header" do
    before do
      get "global_navigation"
    end

    it "returns the header html" do
      response.should render_template(partial: 'layouts/_header')
    end
  end
end

describe ApplicationController, type: :controller do
  controller do
    before_filter :get_escaped_fragment_from_brombone
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
  end
end

describe ApplicationController, 'version expose' do
  before do
    Version.stub(:current) { 'current version' }
  end

  it 'exposes current version' do
    controller.version.should == 'current version'
  end
end

describe ApplicationController do
  describe 'track_event' do

    before do
      @user = Fabricate :user, name: 'Bob Smith', email: 'test@test.com'
      @activity = Fabricate :activity, title: 'Test Activity'
      @like = Fabricate :like, likeable: @activity, user: @user
    end

    it 'creates an event if user signed in' do
      sign_in @user
      controller.send :track_event, @like, 'show'
      Event.first.trackable_id.should == @like.id
      Event.first.trackable_type.should == 'Like'
    end

    it 'does not create an event if user is not signed in' do
      controller.send :track_event, @like, 'show'
      Event.all.length.should == 0
    end

    # it 'does not create an event if trackable is publishable and not published' do
    #   sign_in @user
    #   @unpublished = Fabricate :activity, title: 'Unpublished Activity', published: false
    #   @like_unpublished = Fabricate :like, likeable: @unpublished, user: @user
    #   controller.send :track_event, @like_unpublished
    #   Event.all.length.should == 0
    # end

    # it 'creates an event if the trackable item is not publishable' do
    #   sign_in @user
    #   @upload = Fabricate :upload, title: 'Test Upload', user: @user
    #   @like_upload = Fabricate :like, likeable: @upload, user: @user
    #   controller.send :track_event, @like_upload
    #   Event.first.trackable_id.should == @upload.id
    #   Event.first.trackable_type.should == 'Upload'
    # end

  end

  describe 'brombone' do
    controller do
      before_filter :get_escaped_fragment_from_brombone
      def show
        render text: "Fall through to standard render"
      end
    end

    before do
      @http = mock :http
      Net::HTTP.stub!(:new).and_return @http
    end

    it 'doesnt call brombone for static page when _escaped_fragment_ not present' do
      @http.should_not_receive(:request)
      get :show, id: 1
    end

    it 'calls brombone for static page when _escaped_fragment_ present' do
      resp200 = mock :http_response, code: 200, body: ""
      @http.should_receive(:request).with(an_instance_of(Net::HTTP::Get)).and_return(resp200)
      get :show, id: 1, '_escaped_fragment_' => ''
      expect(response.body).to_not include("Fall through")
    end

    it 'passes through to standard render if brombone errors' do
      resp404 = mock :http_response, code: 404, body: ""
      @http.should_receive(:request).with(an_instance_of(Net::HTTP::Get)).and_return(resp404)
      get :show, id: 1, '_escaped_fragment_' => ''
      expect(response.body).to include("Fall through")
    end

    it 'sets is_brombone when brombone header is in request' do
      request.env["X-Crawl-Request"] = 'brombone'
      get :show, id: 1
      expect is_brombone.should eq(true)
    end
  end
end
