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
      def show
        render text: "Fall through to standard render"
      end
    end

    before do
      @http = mock :http
      Net::HTTP.stub!(:new).and_return @http
    end

    it 'sets is_brombone when brombone header is in request' do
      request.env["X-Crawl-Request"] = 'brombone'
      get :show, id: 1
      expect is_brombone.should eq(true)
    end
  end
end
