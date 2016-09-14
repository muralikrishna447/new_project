describe Api::V0::RecommendationsController do

  before :each do
    @unpub_ad = Fabricate :advertisement, title: "Other Things", image: "{\"url\":\"http://foo/bar\",\"filename\":\"98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"mimetype\":\"image/jpeg\",\"size\":93111,\"key\":\"Vp8xHWW7TRKYRH3FsLBu_98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"container\":\"chefsteps-staging\",\"isWriteable\":true}"
    @non_owner_ad = Fabricate :advertisement, matchname: 'homeHeroNonOwner', published: true, title: "All The Things", image: "{\"url\":\"http://foo/bar\",\"filename\":\"98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"mimetype\":\"image/jpeg\",\"size\":93111,\"key\":\"Vp8xHWW7TRKYRH3FsLBu_98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"container\":\"chefsteps-staging\",\"isWriteable\":true}"
    @owner_ad = Fabricate :advertisement, matchname: 'homeHeroOwner', published: true, title: "Owner All The Things", image: "{\"url\":\"http://foo/bar\",\"filename\":\"98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"mimetype\":\"image/jpeg\",\"size\":93111,\"key\":\"Vp8xHWW7TRKYRH3FsLBu_98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"container\":\"chefsteps-staging\",\"isWriteable\":true}"
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
  it 'should respond new-skool style if platform set, known slot, and signed out' do
    get :index, { platform: 'jouleApp', page: '/lasers', slot: 'homeHero', limit: 3}
    response.should be_success
    parsed = JSON.parse response.body
    parsed['results'].count.should eq 1
    parsed['results'][0]['title'].should eq 'All The Things'
    parsed['results'][0]['image'].should eq 'http://foo/bar'
  end

  it 'should respond new-skool style if known platform set, known slot, and signed in as circ owner' do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt

    @circulator = Fabricate :circulator, notes: 'some notes', circulator_id: '1212121212121212', name: 'my name'
    @circulator_user = Fabricate :circulator_user, user: @user, circulator: @circulator, owner: true
    sign_in @user
    get :index, { platform: 'jouleApp', page: '/lasers', slot: 'homeHero', limit: 3}
    response.should be_success
    parsed = JSON.parse response.body
    parsed['results'].count.should eq 1
    parsed['results'][0]['title'].should eq 'Owner All The Things'
  end

  it 'should respond new-skool but empty if not known platform' do
    get :index, { platform: 'blah', page: '/lasers', slot: 'homeHero', limit: 3}
    response.should be_success
    parsed = JSON.parse response.body
    parsed['results'].count.should eq 0
  end

  it 'should respond new-skool but empty if not known slot' do
    get :index, { platform: 'jouleApp', page: '/lasers', slot: 'blah', limit: 3}
    response.should be_success
    parsed = JSON.parse response.body
    parsed['results'].count.should eq 0
  end
end
