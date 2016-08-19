describe Api::V0::RecommendationsController do

  before :each do
    @unpub_ad = Fabricate :advertisement, title: "Other Things", image: "{\"url\":\"http://foo/bar\",\"filename\":\"98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"mimetype\":\"image/jpeg\",\"size\":93111,\"key\":\"Vp8xHWW7TRKYRH3FsLBu_98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"container\":\"chefsteps-staging\",\"isWriteable\":true}"
    @ad = Fabricate :advertisement, published: true, title: "All The Things", image: "{\"url\":\"http://foo/bar\",\"filename\":\"98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"mimetype\":\"image/jpeg\",\"size\":93111,\"key\":\"Vp8xHWW7TRKYRH3FsLBu_98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"container\":\"chefsteps-staging\",\"isWriteable\":true}"
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
    puts '-----------'
    puts parsed.inspect
    parsed['results'].count.should eq 1
    parsed['results'][0]['title'].should eq 'All The Things'
    parsed['results'][0]['image'].should eq 'http://foo/bar'
  end
end
