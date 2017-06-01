describe Api::V0::RecommendationsController do

  before :each do
    @unpub_ad = Fabricate :advertisement, title: "Other Things", image: "{\"url\":\"http://foo/bar\",\"filename\":\"98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"mimetype\":\"image/jpeg\",\"size\":93111,\"key\":\"Vp8xHWW7TRKYRH3FsLBu_98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"container\":\"chefsteps-staging\",\"isWriteable\":true}"
    @non_owner_ad = Fabricate :advertisement, matchname: 'homeHeroNonOwner', published: true, title: "All The Things", image: "{\"url\":\"http://foo/bar\",\"filename\":\"98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"mimetype\":\"image/jpeg\",\"size\":93111,\"key\":\"Vp8xHWW7TRKYRH3FsLBu_98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"container\":\"chefsteps-staging\",\"isWriteable\":true}"
    @owner_ad = Fabricate :advertisement, matchname: 'homeHeroOwner', published: true, title: "Owner All The Things", image: "{\"url\":\"http://foo/bar\",\"filename\":\"98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"mimetype\":\"image/jpeg\",\"size\":93111,\"key\":\"Vp8xHWW7TRKYRH3FsLBu_98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"container\":\"chefsteps-staging\",\"isWriteable\":true}"

    BetaFeatureService.stub(:user_has_feature).with(anything(), anything())
      .and_return(false)

    @quick_n_easy_ad = Fabricate :advertisement, matchname: 'quickAndEasy',
                                 published: true, title: 'Short on time?'

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

  it 'should respond new-skool style with owner ad if known platform set, known slot, and signed in as circ owner' do
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

  it 'should respond with quick and easy ad if beta feature enabled' do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'

    BetaFeatureService.stub(:user_has_feature).with(@user, 'force_quick_and_easy_ad')
      .and_return(true)

    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
    @circulator = Fabricate :circulator, notes: 'some notes',
                            circulator_id: '1212121212121212', name: 'my name'
    @circulator_user = Fabricate :circulator_user, user: @user,
                                 circulator: @circulator, owner: true
    sign_in @user
    get :index, { platform: 'jouleApp', page: '/lasers', slot: 'homeHero', limit: 3}
    response.should be_success
    parsed = JSON.parse response.body
    parsed['results'].count.should eq 1
    parsed['results'][0]['title'].should eq @quick_n_easy_ad.title
  end

  it 'should return something even if not logged in', :focus => true do
    get :index, {connected: 'true', platform: 'jouleApp', page: '/lasers', slot: 'homeHero', limit: 3}
    response.should be_success
    parsed = JSON.parse response.body
    parsed['results'].count.should eq 1
    parsed['results'][0]['title'].should eq "All The Things"
  end

  it 'should respond new-skool style with owner ad if known platform set, known slot, and signed in as joule purchaser' do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', joule_purchase_count: 1
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt

    sign_in @user
    get :index, { platform: 'jouleApp', page: '/lasers', slot: 'homeHero', limit: 3}
    response.should be_success
    parsed = JSON.parse response.body
    parsed['results'].count.should eq 1
    parsed['results'][0]['title'].should eq 'Owner All The Things'
  end

  it 'should provide a random owner ad if there are more available than requested' do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', joule_purchase_count: 1
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
    @owner_ad2 = Fabricate :advertisement, matchname: 'homeHeroOwner', published: true, title: "More Things", image: "{\"url\":\"http://foo/bar\",\"filename\":\"98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"mimetype\":\"image/jpeg\",\"size\":93111,\"key\":\"Vp8xHWW7TRKYRH3FsLBu_98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"container\":\"chefsteps-staging\",\"isWriteable\":true}"
    sign_in @user
    Utils.should_receive(:weighted_random_sample).and_return([@owner_ad2])
    get :index, { platform: 'jouleApp', page: '/lasers', slot: 'homeHero', limit: 1}
    response.should be_success
    parsed = JSON.parse response.body
    parsed['results'].count.should eq 1
    parsed['results'][0]['title'].should eq 'More Things'
  end

  it 'should respond new-skool style with owner ad if known platform set, known slot, and connected param is true' do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt

    sign_in @user
    get :index, { platform: 'jouleApp', page: '/lasers', slot: 'homeHero', limit: 1, connected: 'true'}
    response.should be_success
    parsed = JSON.parse response.body
    parsed['results'].count.should eq 1
    parsed['results'][0]['title'].should eq 'Owner All The Things'
  end

  it 'should not include referral ad if no referral code for user'do
    @refer_ad = Fabricate :advertisement, add_referral_code: true, matchname: 'homeHeroOwner', published: true, title: "Refer Madness", image: "{\"url\":\"http://foo/bar\",\"filename\":\"98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"mimetype\":\"image/jpeg\",\"size\":93111,\"key\":\"Vp8xHWW7TRKYRH3FsLBu_98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"container\":\"chefsteps-staging\",\"isWriteable\":true}"
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
    sign_in @user
    get :index, { platform: 'jouleApp', page: '/lasers', slot: 'homeHero', limit: 2, connected: 'true'}
    response.should be_success
    parsed = JSON.parse response.body
    parsed['results'].count.should eq 1
  end

  it 'should include referral ad and adjust url if user has referral code' do
    target_url = "/refer?title=Here's%20a%20referral%20code!&description=It's%20pretty%20groovy,%20but%20it%20doesn't%20work!&shareMessage=Share%20this%20will%20your%20pals:%20https:%252F%252Fwww.chefsteps.com%252Fjoule%3Fcode%3DXXXXXX&shareSubject=Hint:%20You%20Should%20Buy%20Joule&discountAmount=50%25"
    expect_url = "/refer?title=Here's%20a%20referral%20code!&description=It's%20pretty%20groovy,%20but%20it%20doesn't%20work!&shareMessage=Share%20this%20will%20your%20pals:%20https:%252F%252Fwww.chefsteps.com%252Fjoule%3Fcode%3Dborscht&shareSubject=Hint:%20You%20Should%20Buy%20Joule&discountAmount=50%25&discountCode=borscht"
    @refer_ad = Fabricate :advertisement, weight: 100, url: target_url, add_referral_code: true, matchname: 'homeHeroOwner', published: true, title: "Refer Madness", image: "{\"url\":\"http://foo/bar\",\"filename\":\"98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"mimetype\":\"image/jpeg\",\"size\":93111,\"key\":\"Vp8xHWW7TRKYRH3FsLBu_98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"container\":\"chefsteps-staging\",\"isWriteable\":true}"
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', referral_code: 'borscht'
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
    sign_in @user
    get :index, { platform: 'jouleApp', page: '/lasers', slot: 'homeHero', limit: 2, connected: 'true'}
    response.should be_success
    parsed = JSON.parse response.body
    parsed['results'].count.should eq 2
    [parsed['results'][0]['url'], parsed['results'][1]['url']] .should include expect_url
  end

  it 'should include only referral ad and adjust url if user has referral code and slot is referPage' do
    target_url = "/refer?title=Here's%20a%20referral%20code!&description=It's%20pretty%20groovy,%20but%20it%20doesn't%20work!&shareMessage=Share%20this%20will%20your%20pals:%20https:%252F%252Fwww.chefsteps.com%252Fjoule%3Fcode%3DXXXXXX&shareSubject=Hint:%20You%20Should%20Buy%20Joule&discountAmount=50%25"
    expect_url = "/refer?title=Here's%20a%20referral%20code!&description=It's%20pretty%20groovy,%20but%20it%20doesn't%20work!&shareMessage=Share%20this%20will%20your%20pals:%20https:%252F%252Fwww.chefsteps.com%252Fjoule%3Fcode%3Dborscht&shareSubject=Hint:%20You%20Should%20Buy%20Joule&discountAmount=50%25&discountCode=borscht"
    @refer_ad = Fabricate :advertisement, weight: 100, url: target_url, add_referral_code: true, matchname: 'homeHeroOwner', published: true, title: "Refer Madness", image: "{\"url\":\"http://foo/bar\",\"filename\":\"98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"mimetype\":\"image/jpeg\",\"size\":93111,\"key\":\"Vp8xHWW7TRKYRH3FsLBu_98rjmQR0RrC3wcxCwqTv_Joule-5-visual-doneness.jpg\",\"container\":\"chefsteps-staging\",\"isWriteable\":true}"
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', referral_code: 'borscht'
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
    sign_in @user
    get :index, { platform: 'jouleApp', page: '/lasers', slot: 'referPage', limit: 2, connected: 'true'}
    response.should be_success
    parsed = JSON.parse response.body
    parsed['results'].count.should eq 1
    parsed['results'][0]['url'].should eq expect_url
  end

  it 'should respond new-skool style with non owner ad if known platform set, known slot, and not owner, purchaser, or connected' do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt

    sign_in @user
    get :index, { platform: 'jouleApp', page: '/lasers', slot: 'homeHero', limit: 3, connected: "false"}
    response.should be_success
    parsed = JSON.parse response.body
    parsed['results'].count.should eq 1
    parsed['results'][0]['title'].should eq 'All The Things'
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

  describe 'bacon hack' do
    before :each do
      @bacon_ad = Fabricate :advertisement, matchname: 'homeHeroOwner', published: true, title: "Bacon", url: "/#/guide/2xIIxBtjwAKSMiWIOAOC4i/overview", campaign: "baconGuideAd"
      @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
      controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt

      sign_in @user
    end

    it 'should not include bacon if version is not set' do
      get :index, { platform: 'jouleApp', page: '/lasers', slot: 'homeHero', limit: 2, connected: 'true'}
      response.should be_success
      parsed = JSON.parse response.body
      parsed['results'].count.should eq 1
    end

    it 'should not include bacon if version is too low' do
      @request.env['X-Application-Version'] = '2.41'
      get :index, { platform: 'jouleApp', page: '/lasers', slot: 'homeHero', limit: 2, connected: 'true'}
      response.should be_success
      parsed = JSON.parse response.body
      parsed['results'].count.should eq 1
    end

    it 'should  include bacon if version is sufficient' do
      @request.env['X-Application-Version'] = '2.42'
      get :index, { platform: 'jouleApp', page: '/lasers', slot: 'homeHero', limit: 2, connected: 'true'}
      response.should be_success
      parsed = JSON.parse response.body
      parsed['results'].count.should eq 2
    end

  end
end
