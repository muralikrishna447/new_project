describe Api::V0::UsersController do

  before :each do
    @user = Fabricate :user, id: 100, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
    @aa = ActorAddress.create_for_user @user, client_metadata: "test"
    @token = 'Bearer ' + @aa.current_token.to_jwt
    BetaFeatureService.stub(:user_has_feature).with(@user, anything()) \
      .and_return(false)
  end

  context 'GET /me' do
    it 'should return a users info when a valid token is provided' do
      request.env['HTTP_AUTHORIZATION'] = @token

      get :me

      response.code.should == "200"
      result = JSON.parse(response.body)

      # TODO - write a nice utility for this sort of comparison
      result.delete('id').should == @user.id
      result.delete('name').should == @user.name
      result.delete('email').should == @user.email
      result.delete('slug').should == @user.slug
      result.delete('avatar_url').should == @user.avatar_url
      result.delete('intercom_user_hash').should == ApplicationController.new.intercom_user_hash(@user)
      result.delete('needs_special_terms').should == @user.needs_special_terms
      result.delete('encrypted_bloom_info')

      result.delete('request_id')
      result.delete('premium').should == false
      result.delete('used_circulator_discount').should == false
      result.delete('admin').should == false
      result.delete('joule_purchase_count').should == 0
      result.empty?.should == true
    end

    it 'should work with old style auth token' do
      old_style_token = AuthToken.new({'address_id' => @aa.address_id, 'User' => {'id' => @user.id}, 'seq' => @aa.sequence})
      request.env['HTTP_AUTHORIZATION'] = old_style_token.to_jwt
      get :me
      response.code.should == "200"
    end

    it 'should include admin flag when user is admin' do
      @user.role = 'admin'
      @user.save!

      request.env['HTTP_AUTHORIZATION'] = @token
      get :me

      result = JSON.parse(response.body)
      result['admin'].should == true
    end

    it 'should not return a users info when a token is missing' do
      get :me
      response.should_not be_success
    end
  end

  context 'POST /create' do
    it 'should create a user' do
      Resque.should_receive(:enqueue).with(Forum, "initial_user", "bloomAPI", kind_of(Numeric))
      Resque.should_receive(:enqueue).with(UserSync, kind_of(Numeric))
      post :create, user: {name: "New User", email: "newuser@chefsteps.com", password: "newUserPassword"}
      response.should be_success
    end

    it 'should call email signup' do
      Api::BaseController.any_instance.should_receive(:email_list_signup)
      post :create, user: {name: "New User", email: "newuser@chefsteps.com", password: "newUserPassword"}
      response.should be_success
    end

    it 'should not call email signup if the user opts out' do
      Api::BaseController.any_instance.should_not_receive(:email_list_signup)
      post :create, optout: "true", user: {name: "New User", email: "newuser@chefsteps.com", password: "newUserPassword"}
      response.should be_success
    end

    it 'should not create a user if required fields are missing' do
      post :create, user: {email: "newuser@chefsteps.com", password: "newUserPassword"}
      response.should_not be_success
    end

    it 'should respond with an error if user already exists' do
      post :create, user: {name: "New User", email: "newuser@chefsteps.com", password: "newUserPassword"}
      post :create, user: {name: "Another New User", email: "newuser@chefsteps.com", password: "newUserPassword"}
      response.should_not be_success
    end

    it 'should create a new Facebook user' do
      post :create, user: {name: "New Facebook User", email: "newfb@user.com", password: "newUserPassword", provider: "facebook"}
      response.code.should == "403"
    end

    it 'should connect an existing Facebook user' do
      post :create, user: {name: "Existing Facebook User", email: "existingfb@user.com", password: "newUserPassword", provider: "facebook"}
      response.code.should == "403"
      post :create, user: {name: "Existing Facebook User", email: "existingfb@user.com", password: "newUserPassword", provider: "facebook"}
      response.code.should == "403"
    end

    it 'should create a user acquisition object' do
      request.cookies['utm'] = { referrer: 'http://u.ca', utm_campaign: '54-40' }.to_json
      post :create, user: { name: 'Acquired User', email: 'a@u.ca', password: 'tricksy' }

      ua = UserAcquisition.find_all_by_utm_campaign('54-40')
      expect(ua.count).to eq(1)
      expect(ua.first.referrer).to eq('http://u.ca')
    end
  end

  context 'POST /international_joule' do
    it "should add the user to mailchimp" do
      pending "Gotta figure out the mailchimp stuff"
    end
  end

  context 'PUT /update' do
    it 'should update a user' do
      request.env['HTTP_AUTHORIZATION'] = @token
      put :update, id: 100, user: {name: 'Joseph Doe', email: 'mynewemail@user.com' }
      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['name']).to eq('Joseph Doe')
      expect(parsed['email']).to eq('mynewemail@user.com')
    end

    it 'should not update a user without a valid token' do
      put :update, id: 100, user: {name: 'Joseph Doe', email: 'mynewemail@user.com' }
      response.should_not be_success
    end

    it 'should not update a user if token belongs to another user' do
      @another_user = Fabricate :user, id: 105, email: 'jojosmith@chefsteps.com', password: '123456', name: 'Jo Jo smith', role: 'user'
      aa = ActorAddress.create_for_user @another_user, client_metadata: "test"
      another_token = 'Bearer ' + aa.current_token.to_jwt
      request.env['HTTP_AUTHORIZATION'] = another_token
      put :update, id: 100, user: {name: 'Joseph Doe', email: 'mynewemail@user.com' }
      response.should_not be_success
    end
  end

  context 'GET /log_upload_url' do
    it 'should generate an upload url with valid auth token' do
      request.env['HTTP_AUTHORIZATION'] = @token
      get :log_upload_url
      response.should be_success
      JSON.parse(response.body)['upload_url'].should_not be_nil
    end

    it 'should accept invalid auth token' do
      request.env['HTTP_AUTHORIZATION'] = @token+'gibberish'
      get :log_upload_url
      response.should be_success
      JSON.parse(response.body)['upload_url'].should_not be_nil
    end

    it 'should generate an upload url without an auth token' do
      get :log_upload_url
      response.should be_success
      JSON.parse(response.body)['upload_url'].should_not be_nil
    end
  end

  context 'GET /capabilities' do
    it 'get empty list if no capabilities' do
      request.env['HTTP_AUTHORIZATION'] = @token
      get :capabilities
      response.should be_success
    end

    it 'get beta_guides capability' do
      request.env['HTTP_AUTHORIZATION'] = @token
      BetaFeatureService.stub(:user_has_feature).with(@user, 'beta_guides')
        .and_return(true)
      get :capabilities
      response.should be_success
      JSON.parse(response.body)['capabilities'].should == ['beta_guides']
    end

    it 'get return error if not logged in' do
      get :capabilities
      response.code.should == '401'
    end
  end
end
