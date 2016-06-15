describe Api::V0::AuthController do

  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    @other_user = Fabricate :user, email: 'jane@chefsteps.com', password: 'matter', name: 'Jane'
    @key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
    @aa = ActorAddress.create_for_user @user, client_metadata: "cooking_app"
  end

  context 'POST /authenticate' do

    it 'should return a 400 when called with bad parameters' do
      post :authenticate
      response.should_not be_success
      response.code.should eq("400")
    end

    it 'should return a status 401 Unauthorized if the password is incorrect' do
      post :authenticate, user: {email: 'johndoe@chefsteps.com', password: 'abcdef'}, client_metadata: 'cooking_app'
      response.should_not be_success
      response.code.should eq("403")
    end

    it 'should work authenticate if email case does not match' do
      post :authenticate, user: {email: 'JOHNdoe@chefsteps.com', password: '123456'}, client_metadata: "cooking_app"
      response.code.should == "200"
    end

    it 'should persist client metadata' do
      post :authenticate, user: {email: 'johndoe@chefsteps.com', password: '123456'}, client_metadata: "cooking_app"
      response.code.should eq("200")
      token = AuthToken.from_string JSON.parse(response.body)['token']
      address_id = token['a']
      ActorAddress.where(address_id: address_id).first.client_metadata.should == 'cooking_app'
    end

    it 'should re-use an existing address' do
      post :authenticate, user: {email: 'johndoe@chefsteps.com', password: '123456'},
        token: @aa.current_token.to_jwt
      response.code.should eq("200")
      token = JSON.parse(response.body)['token']

      decoded = JSON.parse(UrlSafeBase64.decode64(token.split('.')[1]))

      decoded['a'].should == @aa.address_id
      decoded['seq'].should == (@aa.sequence + 2)
    end

    it 'should reject mismatched token' do
      @aa.revoke
      post :authenticate, user: {email: 'johndoe@chefsteps.com', password: '123456'},
        token: @aa.current_token.to_jwt

      response.should_not be_success
      response.code.should eq("403")
    end

    it 'should reject improperly signed token' do
      token = @aa.current_token.to_jwt
      chunks = token.split('.')
      chunks[2] = "gibberishsignature"
      forged_token = chunks.join(".")
      post :authenticate, user: {email: 'johndoe@chefsteps.com', password: '123456'},
        token: forged_token

      response.should_not be_success
      response.code.should eq("403")
    end

    describe 'token' do
      before :each do
        post :authenticate, user: {email: 'johndoe@chefsteps.com', password: '123456'}, client_metadata: 'cooking_app'
        response.should be_success
        response.code.should eq("200")
        @token = JSON.parse(response.body)['token']
      end

      it 'should be returned' do
        @token.should_not be_empty
      end

      it 'should be authenticatable with a valid secret' do
        verified = JSON::JWT.decode(@token, @key.to_s)
        verified['a'].should_not be_empty
      end
    end
  end

  context 'GET /validate' do

    before :each do
      issued_at = (Time.now.to_f * 1000).to_i

      service_claim = {
        iat: issued_at,
        service: 'Messaging'
      }
      @service_token = JSON::JWT.new(service_claim.as_json).sign(@key.to_s).to_s

      @user = Fabricate(:user, id: 200, email: 'user@chefsteps.com',
                        password: '123456', name: 'A User', role: 'user')
      @circulator = Fabricate(:circulator, notes: 'some notes',
                              circulator_id: '1212121212121212')
      CirculatorUser.create(user: @user, circulator: @circulator, owner: true)
      @other_circulator = Fabricate(:circulator, notes: 'some other notes',
                              circulator_id: '9912121212121299')
      @user.circulators = [@circulator]


      @for_circ = ActorAddress.create_for_circulator(@circulator)
      @for_other_circ = ActorAddress.create_for_circulator(@other_circulator)
      @for_user = ActorAddress.create_for_user @user, client_metadata: "test"

      @valid_token = @for_user.current_token.to_jwt
      @invalid_token = 'Bearer Some Bad Token'
    end

    it 'should validate if provided a valid service token' do
      request.env['HTTP_AUTHORIZATION'] = @service_token
      get :validate, token: @valid_token
      response.should be_success
      json_resp = JSON.parse(response.body)
      expect(json_resp['tokenValid']).to be_true
      expect(json_resp['actorType']).to eq('User')
    end

    it 'should have correct addressable_addresses field' do
      request.env['HTTP_AUTHORIZATION'] = @service_token
      get :validate, token: @valid_token
      response.should be_success
      json_resp = JSON.parse(response.body)
      expect(json_resp['addressableAddresses']).to eq([@for_circ.address_id])
    end

    it 'should not validate if no valid service token provided' do
      get :validate
      response.should_not be_success
    end

    it 'should not validate if valid service token provided but token to be validated is invalid' do
      request.env['HTTP_AUTHORIZATION'] = @service_token
      get :validate, token: @invalid_token
      response.should_not be_success
      expect(JSON.parse(response.body)['tokenValid']).to be_false
    end
  end

  context 'POST /logout' do
    it 'should log out properly' do
      request.env['HTTP_AUTHORIZATION'] = @aa.current_token.to_jwt
      post :logout
      response.code.should eq("200")
    end

    it 'should return error when no token supplied' do
      post :logout
      response.code.should eq("401")
    end
  end

  context 'POST /authenticate_facebook' do

    before :each do
      @facebook_app_id = controller.facebook_app_id
      @fake_app_access_token = 'fakeAppAccessToken'
      @fake_user_access_token = 'fakeUserAccessToken'

      oauth = mock(:oauth, get_app_access_token: @fake_app_access_token)
      Koala::Facebook::OAuth.stub!(:new).and_return(oauth)

      # Mock Koala::Facebook::API App Access
      Koala::Facebook::API.stub!(:new).with(@fake_app_access_token)
      @fb = Koala::Facebook::API.new(@fake_app_access_token)


      # Mock Koala::Facebook::API for User Graph Info
      Koala::Facebook::API.stub!(:new).with(@fake_user_access_token)
      @fb_user_api = Koala::Facebook::API.new(@fake_user_access_token)

    end

    it 'should return a token for a new user connecting with Facebook' do
      fb_mock_response = {
        "data" => {
          "is_valid" => true,
          "user_id" => '6789',
          "app_id" => @facebook_app_id
        }
      }
      @fb.stub(:debug_token).with(@fake_user_access_token).and_yield fb_mock_response

      fb_user_api_mock_response = {
        "id" => '6789',
        "email" => 'test@test.com',
        "name" => 'Test User'
      }
      @fb_user_api.stub(:get_object).with('me').and_return fb_user_api_mock_response

      user = {
        access_token: @fake_user_access_token,
        user_id: '6789'
      }
      post :authenticate_facebook, {user:user}
      expect(response.code).to eq("200")
      expect(response.body['token']).not_to be_empty
      expect(response.body['newUser']).to be_true
    end

    it 'should return a token for an existing user connecting with Facebook' do
      exiting_user = Fabricate :user, email: 'existing@test.com', password: '123456', name: 'Existing Dude', provider: 'facebook', facebook_user_id: '54321'
      fb_mock_response = {
        "data" => {
          "is_valid" => true,
          "user_id" => '54321',
          "app_id" => @facebook_app_id
        }
      }
      @fb.stub(:debug_token).with(@fake_user_access_token).and_yield fb_mock_response

      fb_user_api_mock_response = {
        "id" => '54321',
        "email" => 'existing@test.com',
        "name" => 'Existing Dude'
      }
      @fb_user_api.stub(:get_object).with('me').and_return fb_user_api_mock_response

      user = {
        access_token: @fake_user_access_token,
        user_id: '54321'
      }
      post :authenticate_facebook, {user:user}
      expect(response.code).to eq("200")
      expect(response.body['token']).not_to be_empty
      u = User.where(email: 'existing@test.com').first
      expect(u.provider).to eq('facebook')
      expect(u.facebook_user_id).to eq('54321')
    end

    it 'should not return a ChefSteps token for an invalid Facebook token' do
      fb_mock_response = {
        "data" => {
          "is_valid" => false,
          "user_id" => '54321',
          "app_id" => @facebook_app_id
        }
      }
      @fb.stub(:debug_token).with(@fake_user_access_token).and_yield fb_mock_response

      user = {
        access_token: @fake_user_access_token,
        user_id: '54321'
      }
      post :authenticate_facebook, {user:user}
      expect(response.code).to eq("403")
    end

    it 'should not return a ChefSteps token if the Facebook token is not valid for the ChefSteps Facebook App' do
      fb_mock_response = {
        "data" => {
          "is_valid" => true,
          "user_id" => '54321',
          "app_id" => 'SomeOtherAppID'
        }
      }
      @fb.stub(:debug_token).with(@fake_user_access_token).and_yield fb_mock_response

      user = {
        access_token: @fake_user_access_token,
        user_id: '54321'
      }
      post :authenticate_facebook, {user:user}
      expect(response.code).to eq("403")
    end

    # TODO Currently we are just logging the case.  When we handle it properly, we can turn this test back on.
    # it 'should return 401 when an existing ChefSteps with provider != facebook tries to log in' do
    #   exiting_user = Fabricate :user, email: 'existing@test.com', password: '123456', name: 'Existing Dude', provider: nil, facebook_user_id: nil
    #   fb_mock_response = {
    #     "data" => {
    #       "is_valid" => true,
    #       "user_id" => '54321',
    #       "app_id" => @facebook_app_id
    #     }
    #   }
    #   @fb.stub(:debug_token).with(@fake_user_access_token).and_yield fb_mock_response
    #
    #   fb_user_api_mock_response = {
    #     "id" => '54321',
    #     "email" => 'existing@test.com',
    #     "name" => 'Existing Dude'
    #   }
    #   @fb_user_api.stub(:get_object).with('me').and_return fb_user_api_mock_response
    #
    #   user = {
    #     access_token: @fake_user_access_token,
    #     user_id: '54321'
    #   }
    #   post :authenticate_facebook, {user:user}
    #   expect(response.code).to eq("401")
    #   expect(response.body['user']).not_to be_empty
    #   expect(response.body['newUser']).to be_false
    # end

    it 'should not create a second actor address with the same unique key when a user logs in twice' do
      exiting_user = Fabricate :user, email: 'existing@test.com', password: '123456', name: 'Existing Dude', provider: 'facebook', facebook_user_id: '54321'
      fb_mock_response = {
        "data" => {
          "is_valid" => true,
          "user_id" => '54321',
          "app_id" => @facebook_app_id
        }
      }
      @fb.stub(:debug_token).with(@fake_user_access_token).and_yield fb_mock_response

      fb_user_api_mock_response = {
        "id" => '54321',
        "email" => 'existing@test.com',
        "name" => 'Existing Dude'
      }
      @fb_user_api.stub(:get_object).with('me').and_return fb_user_api_mock_response

      user = {
        access_token: @fake_user_access_token,
        user_id: '54321'
      }

      # 1st login
      post :authenticate_facebook, {user:user}

      # 2nd login
      post :authenticate_facebook, {user:user}

      expect(response.code).to eq("200")
      expect(response.body['token']).not_to be_empty
      u = User.where(email: 'existing@test.com').first
      expect(u.provider).to eq('facebook')
      expect(u.facebook_user_id).to eq('54321')
    end

  end
  context 'GET /external_redirect' do
    before :each do
      request.env['HTTP_AUTHORIZATION'] = @aa.current_token.to_jwt
    end

    it 'rejects unconfigured but valid path' do
      get :external_redirect, :path => 'https://www.example.org'
      response.code.should == '404'
    end

    it 'rejects invalid path' do
      get :external_redirect, :path => ':/sdas9sd'
      response.code.should == '400'
    end

    it 'handles basic shopify redirect' do
      get :external_redirect, :path => 'http://test.myshopify.com'
      response.code.should == '200'
    end

    it 'handles shopify checkout redirect' do
      get :external_redirect, :path => 'http://test.myshopify.com?checkout_url=http%3A%2F%2Fsomecheckout.com'
      # Actually checking the redirect requires cracking open the encrypted multipass token
      response.code.should == '200'
    end
  end
end
