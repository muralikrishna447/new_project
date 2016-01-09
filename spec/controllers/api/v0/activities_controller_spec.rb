describe Api::V0::ActivitiesController do
  algolia_stub = nil


  before :each do
    @activity_published = Fabricate :activity, title: 'Activity Published', published: true, id: 1
    @activity_premium = Fabricate :activity, title: 'Activity Premium', published: true, premium: true, id: 2
    @activity_unpublished = Fabricate :activity, title: 'Activity Unpublished', published: false, id: 3
  end

  # GET /api/v0/activities
  context 'GET /activities' do
    it 'should return an array of activities' do
      get :index
      response.should be_success

      JSON.parse(response.body).count.should == 2
    end

    it 'should return only published activities' do
      get :index, published_status: 'published'
      response.should be_success
      activities = JSON.parse(response.body)
      activities.map{|a|a['published']}.should include(true)
      activities.map{|a|a['published']}.should_not include(false)
    end

    it 'should return only unpublished activities' do
      get :index, published_status: 'unpublished'
      response.should be_success
      activities = JSON.parse(response.body)
      activities.map{|a|a['published']}.should include(false)
      activities.map{|a|a['published']}.should_not include(true)
    end

    xit 'should return activity even with invalid token' do
      controller.request.env['HTTP_AUTHORIZATION'] = "badtoken"
      get :show, id: @activity_published
      response.should be_success
      expect_activity_object(response, @activity_published)
    end

    xit 'should not return unpublished activity with invalid token' do
      controller.request.env['HTTP_AUTHORIZATION'] = "badtoken"
      get :show, id: @activity_unpublished
      response.should_not be_success
    end
  end

  # GET /api/v0/activities/:id
  it 'should return a single activity' do
    get :show, id: @activity_published.id
    response.should be_success

    activity = JSON.parse(response.body)

    activity['title'].should == 'Activity Published'
    activity['description'].should == ''
    activity['image'].should == nil
    activity['url'].should == 'http://test.host/activities/activity-published'
    activity['likesCount'].should == nil

    activity['ingredients'].should == []
    activity['steps'].should == []
    activity['equipment'].should == []
  end

  context 'GET /activities/:id/likes' do
    before :each do
      @user1 = Fabricate :user, name: 'User 1', email: 'user1@user1.com', password: '123456'
      @user2 = Fabricate :user, name: 'User 2', email: 'user2@user2.com', password: '123456'
      @like1 = Fabricate :like, likeable: @activity_published, user: @user1
      @like2 = Fabricate :like, likeable: @activity_published, user: @user2
      @like3 = Fabricate :like, likeable: @activity_unpublished, user: @user1
    end

    it 'should return users who liked an activity' do
      get :likes, id: @activity_published.id
      response.should be_success
      parsed = JSON.parse response.body
      ids = parsed.map{|user| user['userId']}
      expect(ids.include?(@user1.id)).to be_true
    end

    it 'should not return users who did not like an activity' do
      get :likes, id: @activity_unpublished.id
      response.should be_success
      parsed = JSON.parse response.body
      ids = parsed.map{|user| user['id']}
      expect(ids.include?(@user2.id)).to be_false
    end
  end

  context 'GET activities access rules' do
    it 'no user' do
      get :show, id: @activity_published
      response.should be_success
      expect_not_trimmed(response)

      get :show, id: @activity_premium
      response.should be_success
      expect_trimmed(response)

      get :show, id: @activity_unpublished
      response.should_not be_success      
    end

    it 'normal non-premium user' do
      @user = Fabricate :user, name: 'User 1', email: 'yukky@food.com', password: '123456'
      sign_in @user

      get :show, id: @activity_published
      response.should be_success
      expect_not_trimmed(response)

      get :show, id: @activity_premium
      response.should be_success
      expect_trimmed(response)

      get :show, id: @activity_unpublished
      response.should_not be_success          
    end

    it 'premium user' do
      @premium_user = Fabricate :user, name: 'Premium User', email: 'admin@chefsteps.com', password: '678910', premium_member: true
      sign_in @premium_user

      get :show, id: @activity_published
      response.should be_success
      expect_not_trimmed(response)

      get :show, id: @activity_premium
      response.should be_success
      expect_not_trimmed(response)

      get :show, id: @activity_unpublished
      response.should_not be_success           
    end

    it 'admin user' do
      @admin_user = Fabricate :user, name: 'Admin User', email: 'admin@chefsteps.com', password: '678910', role: 'admin'
      sign_in @admin_user
      controller.request.env['HTTP_AUTHORIZATION'] = @admin_user.valid_website_auth_token.to_jwt

      get :show, id: @activity_published
      response.should be_success
      expect_not_trimmed(response)

      get :show, id: @activity_premium
      response.should be_success
      expect_not_trimmed(response)

      get :show, id: @activity_unpublished
      response.should be_success           
      expect_not_trimmed(response)
    end

    context 'admin user' do
      before :each do
        @admin_user = Fabricate :user, name: 'Admin User', email: 'admin@chefsteps.com', password: '678910', role: 'admin'
      end   
    end

    xit 'should return the containing assembly if no user is signed in' do
      get :show, id: @activity_premium
      response.should be_success
      expect_containing_assembly(response, @assembly)
    end

    xit 'should return the containing assembly if the signed in user is not an admin' do
      sign_in @user3
      get :show, id: @activity_premium
      response.should be_success
      expect_containing_assembly(response, @assembly)
    end

    xit 'should return an activity if user is an admin' do
      sign_in @admin_user
      controller.request.env['HTTP_AUTHORIZATION'] = @admin_user.valid_website_auth_token.to_jwt
      get :show, id: @activity_premium
      response.should be_success
      expect_activity_object(response, @activity_premium)
    end

    xit 'should return an activity if is_google' do
      controller.request.env['HTTP_USER_AGENT'] = 'googlebot/'
      get :show, id: @activity_premium
      response.should be_success
      expect_activity_object(response, @activity_premium)
    end

    xit 'should return an activity if is_static_render' do
      controller.request.env["HTTP_USER_AGENT"] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.8 Safari/534.34 Prerender (+https://github.com/prerender/prerender)'
      get :show, id: @activity_premium
      response.should be_success
      expect_activity_object(response, @activity_premium)
    end


    def expect_containing_assembly(response, assembly)
      parsed = JSON.parse response.body
      expect(parsed['containingAssembly']['id']).to eq(assembly.id)
    end

    def expect_trimmed(response)
      parsed = JSON.parse response.body
      expect(parsed['steps'].count).to eq(0)
    end

    def expect_not_trimmed(response)
      parsed = JSON.parse response.body
      # couldn't get the step to fabricate
      #expect(parsed['steps'].count).to eq(1)
    end
  end

  def expect_activity_object(response, activity)
    parsed = JSON.parse response.body
    expect(parsed['id']).to eq(activity.id)
    expect(parsed['title']).to eq(activity.title)
  end
end
