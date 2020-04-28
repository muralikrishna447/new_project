describe Api::V0::ActivitiesController do
  algolia_stub = nil

  before :each do
    @activity_published = Fabricate :activity, title: 'Activity Published', published: true, id: 1
    @activity_published.steps << Fabricate(:step, activity_id: @activity_published.id, title: 'hello', youtube_id: 'REk30BRVtgE')

    @activity_premium = Fabricate :activity, title: 'Activity Premium', published: true, premium: true, id: 2
    @activity_premium.steps << Fabricate(:step, activity_id: @activity_premium.id, title: 'hello', youtube_id: 'REk30BRVtgE')

    @activity_unpublished = Fabricate :activity, title: 'Activity Unpublished', published: false, id: 3
    @activity_unpublished.steps << Fabricate(:step, activity_id: @activity_unpublished.id, title: 'hello', youtube_id: 'REk30BRVtgE')
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

    it 'should return activity even with invalid token' do
      controller.request.env['HTTP_AUTHORIZATION'] = "badtoken"
      get :show, id: @activity_published
      response.should be_success
      expect_activity_object(response, @activity_published)
    end

    it 'should not return unpublished activity with invalid token' do
      controller.request.env['HTTP_AUTHORIZATION'] = "badtoken"
      get :show, id: @activity_unpublished
      response.should_not be_success
    end

    it 'returns 404 for non-existent activity fetched by id' do
      get :show, id: 99999
      response.status.should == 404
    end

    it 'returns 404 for non-existent activity fetched by slug' do
      get :show, id: 'doesnt-exist'
      response.status.should == 404
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
    activity['steps'].count.should == 1
    activity['equipment'].should == []
  end

  it 'should cache activity JSON' do
    # first one to prime cache
    get :show, id: @activity_published.id

    @activity_published.title = 'bleh'
    @activity_published.save

    get :show, id: @activity_published.id
    activity = JSON.parse(response.body)
    activity['title'].should_not == 'bleh'
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
      expect(ids.include?(@user1.id)).to be true
    end

    it 'should not return users who did not like an activity' do
      get :likes, id: @activity_unpublished.id
      response.should be_success
      parsed = JSON.parse response.body
      ids = parsed.map{|user| user['id']}
      expect(ids.include?(@user2.id)).to be false
    end
  end

  context 'GET /activities/:id/likes_by_user' do
    before :each do
      @user1 = Fabricate :user, name: 'User 1', email: 'user1@user1.com', password: '123456'
      @user2 = Fabricate :user, name: 'User 2', email: 'user2@user2.com', password: '123456'
      @user3 = Fabricate :user, name: 'User 3', email: 'user3@user3.com', password: '123456'
      @like1 = Fabricate :like, likeable: @activity_published, user: @user1
      @like2 = Fabricate :like, likeable: @activity_published, user: @user2
    end

    it 'should return user1s like of an activity' do
      controller.request.env['HTTP_AUTHORIZATION'] = @user1.valid_website_auth_token.to_jwt
      get :likes_by_user, id: @activity_published.id
      response.should be_success
      parsed = JSON.parse response.body
      expect(parsed).to eq([{"id"=>@like1.id, "userId"=>@user1.id}])
    end

    it 'should not return any likes of activity' do
      controller.request.env['HTTP_AUTHORIZATION'] = @user3.valid_website_auth_token.to_jwt
      get :likes_by_user, id: @activity_published.id
      response.should be_success
      parsed = JSON.parse response.body
      expect(parsed).to eq([])
    end
  end

  context 'GET activities access rules' do
    context 'no user' do
      it 'published activity' do
        get :show, id: @activity_published
        expect_not_trimmed(response)
      end

      it 'premium activity' do
        get :show, id: @activity_premium
        expect_trimmed(response)
      end

      it 'unpublished activity' do
        get :show, id: @activity_unpublished
        response.should_not be_success
      end
    end

    context 'prerender.io' do
      before :each do
        controller.request.env['HTTP_USER_AGENT'] = 'prerender'
      end

      it 'published activity' do
        get :show, id: @activity_published
        expect_not_trimmed(response)
      end

      # Prerender should see full text of premium activity
      it 'premium activity' do
        get :show, id: @activity_premium
        expect_not_trimmed(response)
      end

      it 'unpublished activity' do
        get :show, id: @activity_unpublished
        response.should_not be_success
      end
    end

    context 'normal non-premium user' do
      before :each do
        @user = Fabricate :user, name: 'User 1', email: 'yukky@food.com', password: '123456'
        sign_in @user
        controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
      end

      it 'published activity' do
        get :show, id: @activity_published
        expect_not_trimmed(response)
      end

      it 'premium activity' do
        get :show, id: @activity_premium
        expect_trimmed(response)
      end

      it 'unpublished activity' do
        get :show, id: @activity_unpublished
        response.should_not be_success
      end

      it 'their own activity UGC' do
        my_activity = Fabricate :activity, title: 'My Activity', published: false, id: 4, creator: @user
        my_activity.steps << Fabricate(:step, activity_id: my_activity.id, title: 'hello', youtube_id: 'REk30BRVtgE')
        get :show, id: my_activity
        expect_not_trimmed(response)
      end

      # This is the grandfather clause case; i.e. user enrolled in Shrimp Brains class when it was
      # free, never bought a class so they aren't premium, but now we decided to make Shrimp Brains premium.
      # They should still have access.
      context 'grandfather clause' do
        before :each do
          @assembly = Fabricate :assembly, title: 'Assembly 1', description: 'an assembly description', assembly_type: 'Course', published: true, premium: true
          @assembly_inclusion = Fabricate :assembly_inclusion, assembly: @assembly, includable: @activity_premium
        end

        it 'user not enrolled' do
          get :show, id: @activity_premium
          expect_trimmed(response)
        end

        it 'enrolled' do
          enrollment = Fabricate :enrollment, enrollable: @assembly, user: @user
          get :show, id: @activity_premium
          expect_not_trimmed(response)
        end
      end
    end

    context 'premium user' do
      before :each do
        @premium_user = Fabricate :user, name: 'Premium User', email: 'prem@chefsteps.com', password: '678910', premium_member: true
        controller.request.env['HTTP_AUTHORIZATION'] = @premium_user.valid_website_auth_token.to_jwt
        sign_in @premium_user
      end

      it 'published activity' do
        get :show, id: @activity_published
        expect_not_trimmed(response)
      end

      it 'premium activity' do
        get :show, id: @activity_premium
        expect_not_trimmed(response)
      end

      it 'unpublished activity' do
        get :show, id: @activity_unpublished
        response.should_not be_success
      end
    end

    context 'admin user' do
      before :each do
        @admin_user = Fabricate :user, name: 'Admin User', email: 'admin@chefsteps.com', password: '678910', role: 'admin'
        sign_in @admin_user
        controller.request.env['HTTP_AUTHORIZATION'] = @admin_user.valid_website_auth_token.to_jwt
      end

      it 'published activity' do
        get :show, id: @activity_published
        expect_not_trimmed(response)
      end

      it 'premium activity' do
        get :show, id: @activity_premium
        expect_not_trimmed(response)
      end

      it 'unpublished activity' do
        get :show, id: @activity_unpublished
        expect_not_trimmed(response)
      end
    end

    context 'other cancan levels can read unpublished' do
      def try_level(level)
        @user = Fabricate :user, name: 'foober', email: 'foober@chefsteps.com', password: '678910', role: level
        sign_in @user
        controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
        get :show, id: @activity_unpublished
        expect_not_trimmed(response)
      end

      it 'collaborator' do
        try_level('collaborator')
      end

      it 'moderator' do
        try_level('moderator')
      end

      # Contractor role seems really fubar, it has less ability than a generic user, so ignoring for now
      xit 'contractor' do
        try_level('contractor')
      end
    end

    # already enrolled but not premium

    it 'should return an activity if is_google' do
      controller.request.env['HTTP_USER_AGENT'] = 'googlebot/'
      get :show, id: @activity_premium
      response.should be_success
      expect_activity_object(response, @activity_premium)
    end

    def expect_trimmed(response)
      response.should be_success
      parsed = JSON.parse response.body
      expect(parsed['steps']).to eq(nil)
      expect(parsed['ingredients']).to eq(nil)
      expect(parsed['equipment']).to eq(nil)
    end

    def expect_not_trimmed(response)
      response.should be_success
      parsed = JSON.parse response.body
      expect(parsed['steps'].count).to eq(1)
    end
  end

  context 'versions' do
    before :each do
      @revisable_activity = Fabricate :activity, title: 'Revisable Activity', description: 'This is version 1', published: true, id: 5
      @activity_v1 = ActsAsRevisionable::RevisionRecord.new(@revisable_activity)
      @activity_v1.save

      @revisable_activity.description = 'This is version 2'
      @revisable_activity.save

      @activity_v2 = ActsAsRevisionable::RevisionRecord.new(@revisable_activity)
      @activity_v2.save
    end

    it 'loads correct revision when the version parameter is 1' do
      get :show, id: @revisable_activity.id, version: 1
      response.should be_success
      parsed = JSON.parse response.body
      expect(parsed['description']).to eq('This is version 1')
    end

    it 'loads latest version after a revision' do
      get :show, id: @revisable_activity.id, version: 1
      response.should be_success
      parsed = JSON.parse response.body
      expect(parsed['description']).to eq('This is version 1')

      @revisable_activity.description = 'foobar'
      @revisable_activity.save
      activity_v3 = ActsAsRevisionable::RevisionRecord.new(@revisable_activity)
      activity_v3.save

      get :show, id: @revisable_activity.id
      response.should be_success
      parsed = JSON.parse response.body
      expect(parsed['description']).to eq('foobar')
    end

    it 'loads correct revision when the version parameter is 2' do
      get :show, id: @revisable_activity.id, version: 2
      response.should be_success
      parsed = JSON.parse response.body
      expect(parsed['description']).to eq('This is version 2')
    end
  end

  def expect_activity_object(response, activity)
    parsed = JSON.parse response.body
    expect(parsed['id']).to eq(activity.id)
    expect(parsed['title']).to eq(activity.title)
  end
end
