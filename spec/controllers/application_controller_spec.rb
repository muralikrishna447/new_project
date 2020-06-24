require 'spec_helper'

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

  end

  describe 'prerender' do
    controller do
      def show
        render plain: "Fall through to standard render"
      end
    end

    before do
      @http = double :http
      Net::HTTP.stub(:new).and_return @http
    end

    it 'sets is_static_render when prerender header is in user agent' do
      request.env["HTTP_USER_AGENT"] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.8 Safari/534.34 Prerender (+https://github.com/prerender/prerender)'
      get :show, params: {id: 1}
      expect is_static_render.should eq(true)
    end
  end
end
