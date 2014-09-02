describe Api::V0::ActivitiesController do
  
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
      activity['description'].should == nil
      activity['image'].should == nil
      activity['url'].should == 'http://test.host/activities/activity-1'
      activity['likesCount'].should == nil
    end

    it 'should return only published activities' do
      get :index, published: true
      response.should be_success
      activities = JSON.parse(response.body)
      activities.map{|a|a['published']}.should include(true)
      activities.map{|a|a['published']}.should_not include(false)
    end

    it 'should return only unpublished activities' do
      get :index, published: false
      response.should be_success
      activities = JSON.parse(response.body)
      activities.map{|a|a['published']}.should include(false)
      activities.map{|a|a['published']}.should include(true)
    end
  end

  # GET /api/v0/activities/:id
  it 'should return a single activity' do
    get :index, id: @activity1.id
    response.should be_success

    activity = JSON.parse(response.body).first

    activity['title'].should == 'Activity 1'
    activity['description'].should == nil
    activity['image'].should == nil
    activity['url'].should == 'http://test.host/activities/activity-1'
    activity['likesCount'].should == nil

    activity['ingredients'].should == nil
    activity['steps'].should == nil
    activity['equipment'].should == nil
  end
end