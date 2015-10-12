describe Api::V0::ActivitiesController do
  algolia_stub = nil


  before :each do
    @activity1 = Fabricate :activity, title: 'Activity 1', published: true
    @activity2 = Fabricate :activity, title: 'Activity 2', published: false
  end

  # GET /api/v0/activities
  context 'GET /activities' do
    it 'should return an array of activities' do
      get :index
      response.should be_success

      activity = JSON.parse(response.body).first

      activity['title'].should == 'Activity 1'
      activity['description'].should == ''
      activity['image'].should == nil
      activity['url'].should == 'http://test.host/activities/activity-1'
      activity['likesCount'].should == nil
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
  end

  # GET /api/v0/activities/:id
  it 'should return a single activity' do
    get :index, id: @activity1.id
    response.should be_success

    activity = JSON.parse(response.body).first

    activity['title'].should == 'Activity 1'
    activity['description'].should == ''
    activity['image'].should == nil
    activity['url'].should == 'http://test.host/activities/activity-1'
    activity['likesCount'].should == nil

    activity['ingredients'].should == nil
    activity['steps'].should == nil
    activity['equipment'].should == nil
  end

  context 'GET /activities/:id/likes' do
    before :each do
      @user1 = Fabricate :user, name: 'User 1', email: 'user1@user1.com', password: '123456'
      @user2 = Fabricate :user, name: 'User 2', email: 'user2@user2.com', password: '123456'
      @like1 = Fabricate :like, likeable: @activity1, user: @user1
      @like2 = Fabricate :like, likeable: @activity1, user: @user2
      @like3 = Fabricate :like, likeable: @activity2, user: @user1
    end

    it 'should return users who liked an activity' do
      get :likes, id: @activity1.id
      response.should be_success
      parsed = JSON.parse response.body
      ids = parsed.map{|user| user['userId']}
      expect(ids.include?(@user1.id)).to be_true
    end

    it 'should not return users who did not like an activity' do
      get :likes, id: @activity2.id
      response.should be_success
      parsed = JSON.parse response.body
      ids = parsed.map{|user| user['id']}
      expect(ids.include?(@user2.id)).to be_false
    end
  end
end
