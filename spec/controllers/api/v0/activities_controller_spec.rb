describe Api::V0::ActivitiesController do
  
  before :each do
    @activity = Fabricate :activity, title: 'Activity', published: true
  end

  # GET /api/v0/activities
  it 'should return an array of activities' do
    get :index
    response.should be_success

    activity = JSON.parse(response.body).first

    activity['title'].should == 'Activity'
    activity['description'].should == nil
    activity['image'].should == nil
    activity['url'].should == 'http://test.host/activities/activity'
    activity['likesCount'].should == nil
  end

  # GET /api/v0/activities/:id
  it 'should return a single activity' do
    get :index, id: @activity.id
    response.should be_success

    activity = JSON.parse(response.body).first

    activity['title'].should == 'Activity'
    activity['description'].should == nil
    activity['image'].should == nil
    activity['url'].should == 'http://test.host/activities/activity'
    activity['likesCount'].should == nil

    activity['ingredients'].should == nil
    activity['steps'].should == nil
    activity['equipment'].should == nil
  end
end