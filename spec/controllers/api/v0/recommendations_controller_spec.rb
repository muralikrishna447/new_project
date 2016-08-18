describe Api::V0::RecommendationsController do

  before :each do
    @ad = Fabricate :advertisement, title: "All The Things"
    @activity = Fabricate :activity, title: 'My New Recipe', published: true, include_in_gallery: true
    @activity.tag_list.add('garlic')
    @activity.save!
  end

  # GET /api/v0/recommendations - old skool
  it 'should respond old-skool style if no platform set' do
    get :index, { tags:['garlic']}
    response.should be_success
    parsed = JSON.parse response.body
    parsed.count.should eq 1
    parsed[0]['title'].should eq 'My New Recipe'
  end

  # GET /api/v0/recommendations - new skool
  it 'should respond new-skool style if platform set' do
    get :index, { platform: 'spaceLaser', page: '/lasers', slot: 'hero', limit: 3}
    response.should be_success
    parsed = JSON.parse response.body
    parsed.count.should eq 1
    parsed[0]['title'].should eq 'All The Things'
  end
end
