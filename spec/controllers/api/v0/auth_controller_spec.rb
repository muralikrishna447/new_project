describe Api::V0::AuthController do
  include Docs::V0::Auth::Api

  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    @other_user = Fabricate :user, email: 'jane@chefsteps.com', password: 'matter', name: 'Jane'
    @key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
    @aa = ActorAddress.create_for_user @user, client_metadata: "cooking_app"
    # Make sure no tokens are getting logged!
    Rails.logger.stub(:info) do |log_line|
      contains_token = log_line =~ /eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9/
      if contains_token
        raise "Token being logged - #{log_line}"
      end
    end
  end

  describe 'POST #authenticate' do
    include Docs::V0::Auth::Authenticate
    context 'POST /authenticate', :dox do

      it 'should return a 400 when called with bad parameters' do
        post :authenticate
        response.should_not be_success
        response.code.should eq("400")
      end

      it 'should return a status 401 Unauthorized if the password is incorrect' do
        post :authenticate, params: {user: {email: 'johndoe@chefsteps.com', password: 'abcdef'}, client_metadata: 'cooking_app'}
        response.should_not be_success
        response.code.should eq("403")
      end

      it 'should work authenticate if email case does not match' do
        post :authenticate, params: {user: {email: 'JOHNdoe@chefsteps.com', password: '123456'}, client_metadata: "cooking_app"}
        response.code.should == "200"
      end

      it 'should persist client metadata' do
        post :authenticate, params: {user: {email: 'johndoe@chefsteps.com', password: '123456'}, client_metadata: "cooking_app"}
        response.code.should eq("200")
        token = AuthToken.from_string JSON.parse(response.body)['token']
        address_id = token['a']
        ActorAddress.where(address_id: address_id).first.client_metadata.should == 'cooking_app'
      end

      it 'should re-use an existing address' do
        post :authenticate, params: {user: {email: 'johndoe@chefsteps.com', password: '123456'},
          token: @aa.current_token.to_jwt}
        response.code.should eq("200")
        token = JSON.parse(response.body)['token']

        decoded = JSON.parse(UrlSafeBase64.decode64(token.split('.')[1]))

        decoded['a'].should == @aa.address_id
        decoded['seq'].should == (@aa.sequence + 2)
      end

      it 'should reject mismatched token' do
        @aa.revoke
        post :authenticate, params: {user: {email: 'johndoe@chefsteps.com', password: '123456'},
          token: @aa.current_token.to_jwt}

        response.should_not be_success
        response.code.should eq("403")
      end

      it 'should reject improperly signed token' do
        token = @aa.current_token.to_jwt
        chunks = token.split('.')
        chunks[2] = "gibberishsignature"
        forged_token = chunks.join(".")
        post :authenticate, params: {user: {email: 'johndoe@chefsteps.com', password: '123456'},
          token: forged_token}

        response.should_not be_success
        response.code.should eq("403")
      end

      describe 'token' do
        before :each do
          post :authenticate, params: {user: {email: 'johndoe@chefsteps.com', password: '123456'}, client_metadata: 'cooking_app'}
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
  end

  describe 'GET #validate' do
    include Docs::V0::Auth::Validate
    context 'GET /validate', :dox do

      before :each do
        Rails.cache.clear()
        issued_at = (Time.now.to_f * 1000).to_i

        service_claim = {
          iat: issued_at,
          service: 'Messaging'
        }
        @service_token = JSON::JWT.new(service_claim.as_json).sign(@key.to_s).to_s

        @user = Fabricate(:user, id: 200, email: 'user@chefsteps.com',
                          password: '123456', name: 'A User', role: 'user')
        @other_user = Fabricate(:user, id: 201, email: 'user2@chefsteps.com',
                          password: '123456', name: 'Another User', role: 'user')

        @other_circulator = Fabricate(:circulator, notes: 'some other notes',
                                      circulator_id: '9912121212121299')
        CirculatorUser.create(user: @other_user, circulator: @other_circulator, owner: true)


        @circulator = Fabricate(:circulator, notes: 'some notes',
                                circulator_id: '1212121212121212')
        CirculatorUser.create(user: @user, circulator: @circulator, owner: true)

        @user.circulators = [@circulator]


        @for_circ = ActorAddress.create_for_circulator(@circulator)
        @for_other_circ = ActorAddress.create_for_circulator(@other_circulator)
        @for_user = ActorAddress.create_for_user @user, client_metadata: "test"

        @valid_token = @for_user.current_token.to_jwt
        @valid_circ_token = @for_circ.current_token.to_jwt
        @invalid_token = 'Bearer Some Bad Token'

        BetaFeatureService.stub(:user_has_feature).with(anything, anything, anything)
          .and_return(false)
        BetaFeatureService.stub(:get_groups_for_user).with(anything)
          .and_return([])
      end

      it 'should validate if provided a valid service token' do
        request.env['HTTP_AUTHORIZATION'] = @service_token
        get :validate, params: {token: @valid_token}
        response.should be_success
        json_resp = JSON.parse(response.body)
        expect(json_resp['tokenValid']).to be true
        expect(json_resp['actorType']).to eq('User')
      end

      it 'should have correct addressable_addresses field' do
        request.env['HTTP_AUTHORIZATION'] = @service_token
        get :validate, params: {token: @valid_token}
        response.should be_success
        json_resp = JSON.parse(response.body)
        expect(json_resp['addressableAddresses']).to eq([@for_circ.address_id])
      end

      it 'user should have empty capabilities' do
        request.env['HTTP_AUTHORIZATION'] = @service_token
        get :validate, params: {token: @valid_token}
        response.should be_success
        json_resp = JSON.parse(response.body)
        expect(json_resp['capabilities']).to eq([])
      end

      it 'circ should have predictive capability if enabled' do
        BetaFeatureService.stub(:user_has_feature).with(@user, 'predictive', anything)
          .and_return(true)
        request.env['HTTP_AUTHORIZATION'] = @service_token
        get :validate, params: {token: @valid_circ_token}
        response.should be_success
        json_resp = JSON.parse(response.body)
        expect(json_resp['capabilities']).to eq(['predictive'])
      end

      it 'circ should have not have predictive capability if not enabled' do
        request.env['HTTP_AUTHORIZATION'] = @service_token
        get :validate, params: {token: @valid_circ_token}
        response.should be_success
        json_resp = JSON.parse(response.body)
        expect(json_resp['capabilities']).to eq([])
      end

      it 'should not validate if no valid service token provided' do
        get :validate
        response.should_not be_success
      end

      it 'should not validate if valid service token provided but token to be validated is invalid' do
        request.env['HTTP_AUTHORIZATION'] = @service_token
        get :validate, params: {token: @invalid_token}
        response.code.should == "400"
        expect(JSON.parse(response.body)['tokenValid']).to be_falsy
      end
    end
  end

  describe 'POST #logout' do
    include Docs::V0::Auth::Logout
    context 'POST /logout', :dox do
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
  end

  describe 'GET #authorize_ge_redirect' do
    include Docs::V0::Auth::AuthorizeGeRedirect
    context 'GET /authorize_ge_redirect', :dox do
      before do
        @short_lived_token = AuthToken.provide_short_lived(@aa.current_token).to_jwt
        controller.request.env['HTTP_AUTHORIZATION'] = "Bearer #{@short_lived_token}"
      end

      it "should return a redirect" do
        get :authorize_ge_redirect
        response.code.should eq("200")
        response.body.should include("geappliances.com")
      end

      it "should have the user id encoded in state" do
        get :authorize_ge_redirect
        body = JSON.parse(response.body)
        url = Rack::Utils.parse_nested_query(body["redirect"])
        decoded = JWT.decode(url["state"], ENV['OAUTH_SECRET']).first
        decoded["id"].should eq(@user.id)
      end
    end
  end

  describe 'GET #authenticate_ge' do
    include Docs::V0::Auth::AuthenticateGe
    context 'GET /authenticate_ge', :dox do
      before do
        GE::Client.stub_chain(:auth_code, :get_token, :token).and_return("ABC123")
        GE::Client.stub_chain(:auth_code, :get_token, :expires_at).and_return(Time.now)
        GE::Client.stub_chain(:auth_code, :get_token, :refresh_token).and_return("ZYX999")
        @state = JWT.encode({
            unique: Time.now.to_f, # Could be used to help prevent replay attacks
            id: @user.id
        }, ENV['OAUTH_SECRET'])
      end

      it "should return a ge token" do
        get :authenticate_ge, params: {code: "DEF456", state: @state}
        response.code.should eq("200")
        body = JSON.parse(response.body)
        body["message"].should eq("Success.")
        body["token"].should eq("ABC123")
      end

      it "should return a ge token if a token already exists for a user" do
        oauth_token = Fabricate :oauth_token, user_id: @user.id, service: "ge", token: "abc123", token_expires_at: Time.now
        get :authenticate_ge, params: {code: "DEF456", state: @state}
        response.code.should eq("200")
        body = JSON.parse(response.body)
        body["message"].should eq("Success.")
        body["token"].should eq("ABC123")
        oauth_token.reload
        oauth_token.token.should eq("ABC123")
      end

      it "should return an error if user doesn't exist" do
        @state = JWT.encode({
            unique: Time.now.to_f, # Could be used to help prevent replay attacks
            id: 1 # This is fake
        }, ENV['OAUTH_SECRET'])
        get :authenticate_ge, params: {code: "DEF456", state: @state}
        response.code.should eq("401")
        body = JSON.parse(response.body)
        body["message"].should eq("Invalid user")
      end

      it "should return an error if it doesn't receive a token" do
        GE::Client.stub_chain(:auth_code, :get_token).and_raise(OAuth2::Error.new(OpenStruct.new({error: :invalid_token, error_description: "test"})))
        get :authenticate_ge, params: {code: "DEF456", state: @state}
        response.code.should eq("401")
        body = JSON.parse(response.body)
        body["message"].should eq("Invalid token")
      end
    end
  end

  describe 'POST #authenticate_facebook' do
    include Docs::V0::Auth::AuthenticateFacebook
    context 'POST /authenticate_facebook', :dox do

      before :each do
        @facebook_app_id = controller.facebook_app_id
        @fake_app_access_token = 'fakeAppAccessToken'
        @fake_user_access_token = 'fakeUserAccessToken'

        oauth = double(:oauth, get_app_access_token: @fake_app_access_token)
        Koala::Facebook::OAuth.stub(:new).and_return(oauth)

        # Mock Koala::Facebook::API App Access
        Koala::Facebook::API.stub(:new).with(@fake_app_access_token)
        @fb = Koala::Facebook::API.new(@fake_app_access_token)


        # Mock Koala::Facebook::API for User Graph Info
        Koala::Facebook::API.stub(:new).with(@fake_user_access_token)
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
        puts "HERE: #{@fake_user_access_token}"
        @fb_user_api.stub(:get_object).with('me', {fields: 'email,name,id'}).and_return fb_user_api_mock_response

        user = {
          access_token: @fake_user_access_token,
          user_id: '6789'
        }
        post :authenticate_facebook, params: {user:user}
        response_body = JSON.parse(response.body)
        expect(response.code).to eq("200")
        expect(response_body['token']).not_to be_empty
        expect(response_body['newUser']).to be true
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
        @fb_user_api.stub(:get_object).with('me', {:fields=>"email,name,id"}).and_return fb_user_api_mock_response

        user = {
          access_token: @fake_user_access_token,
          user_id: '54321'
        }
        post :authenticate_facebook, params: {user:user}
        expect(response.code).to eq("200")
        expect(response.body['token']).not_to be_empty
        u = User.where(email: 'existing@test.com').first
        expect(u.provider).to eq('facebook')
        expect(u.facebook_user_id).to eq('54321')
      end

      it 'should return a 400 if the Facebook user account is missing an email field' do
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
          "name" => 'Existing Dude'
        }
        @fb_user_api.stub(:get_object).with('me', {:fields=>"email,name,id"}).and_return fb_user_api_mock_response

        user = {
          access_token: @fake_user_access_token,
          user_id: '54321'
        }
        post :authenticate_facebook, params: {user:user}
        expect(response.code).to eq("400")
        # expect(response.body['token']).not_to be_empty
        # u = User.where(email: 'existing@test.com').first
        # expect(u.provider).to eq('facebook')
        # expect(u.facebook_user_id).to eq('54321')
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
        post :authenticate_facebook, params: {user:user}
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
        post :authenticate_facebook, params: {user:user}
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
      #   expect(response.body['newUser']).to be false
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
        @fb_user_api.stub(:get_object).with('me', {:fields=>"email,name,id"}).and_return fb_user_api_mock_response

        user = {
          access_token: @fake_user_access_token,
          user_id: '54321'
        }

        # 1st login
        post :authenticate_facebook, params: {user:user}

        # 2nd login
        post :authenticate_facebook, params: {user:user}

        expect(response.code).to eq("200")
        expect(response.body['token']).not_to be_empty
        u = User.where(email: 'existing@test.com').first
        expect(u.provider).to eq('facebook')
        expect(u.facebook_user_id).to eq('54321')
      end

    end
  end

  describe 'POST #authenticate_apple' do
    include Docs::V0::Auth::AuthenticateApple
    context 'POST authenticate_apple', :dox do
      let(:identity_token) { 'identity_token' }
      let(:apple_user_id) { 'apple_user_id' }
      let(:auth_code) { 'auth_code' }
      let(:fullname) { 'User Name' }
      let(:params) { { identity_token: identity_token, auth_code: auth_code, name: fullname } }

      context 'token is invalid' do
        before :each do
          allow(CsAuth::Apple).to receive(:decode_and_validate_token)
              .with(identity_token, auth_code).and_raise CsAuth::Apple::InvalidTokenError
        end

        it 'renders unauthorized' do
          post :authenticate_apple, params: params
          expect(response.code).to eq('403')
        end
      end

      context 'token is valid' do
        let(:decoded_token) { { 'email' => token_email, 'sub' => apple_user_id } }

        before :each do
          allow(CsAuth::Apple).to receive(:decode_and_validate_token)
              .with(identity_token, auth_code).and_return(decoded_token)
        end

        context 'apple user email matches existing user' do
          before :each do
            Fabricate :user, email: existing_email, password: '123456', name: fullname, provider: provider, apple_user_id: existing_apple_user_id
          end

          context 'with another account matching apple user id' do
            before :each do
              Fabricate :user, email: 'b@b.com', password: '123456', name: fullname, provider: 'email', apple_user_id: nil
            end

            let(:existing_apple_user_id) { apple_user_id }
            let(:provider)  { 'apple' }
            let(:existing_email) { 'a@a.com' }
            let(:token_email) { 'b@b.com' }

            it 'issues token with newUser false for account with matching apple user id' do
              post :authenticate_apple, params: params
              expect(response.code).to eq('200')
              body = JSON.parse(response.body)
              expect(body.fetch('newUser')).to be false
              apple_user = User.find_by(apple_user_id: existing_apple_user_id)
              expect(body['token']).to eq(ActorAddress.find_for_user_and_unique_key(apple_user, provider).current_token.to_jwt)
            end
          end

          context 'with account having non-apple provider' do
            let(:existing_apple_user_id) { nil }
            let(:provider) { 'email' }
            let(:existing_email) { 'a@a.com' }
            let(:token_email) { existing_email }

            it 'renders 409 conflict' do
              post :authenticate_apple, params: params
              expect(response.code).to eq('409')
              expect(JSON.parse(response.body).fetch('reason')).to eq('EXISTING_ACCOUNT_WITH_EMAIL')
              expect(User.find_by(apple_user_id: apple_user_id)).to be nil
            end
          end
        end

        context 'no existing user with email provider' do
          let(:token_email) { 'a@a.com' }
          let(:provider) { 'apple' }

          context 'user with matching apple id exists' do
            before :each do
              Fabricate :user, email: token_email, password: '123456', name: fullname, provider: provider, apple_user_id: apple_user_id
            end

            it 'issues token with newUser false' do
              post :authenticate_apple, params: params
              expect(response.code).to eq('200')
              body = JSON.parse(response.body)
              expect(body.fetch('newUser')).to be false
              apple_user = User.find_by(apple_user_id: apple_user_id)
              expect(body['token']).to eq(ActorAddress.find_for_user_and_unique_key(apple_user, provider).current_token.to_jwt)
            end
          end

          context 'user with matching apple id does not exist' do
            it 'creates user with apple id and issues token with newUser true' do
              post :authenticate_apple, params: params
              expect(response.code).to eq('200')
              body = JSON.parse(response.body)
              expect(body.fetch('newUser')).to be true
              user = User.find_by(apple_user_id: apple_user_id)
              expect(user).not_to be nil
              expect(user.email).to eq(token_email)
              expect(user.name).to eq(fullname)
              expect(body['token']).to eq(ActorAddress.find_for_user_and_unique_key(user, provider).current_token.to_jwt)
            end
          end
        end
      end
    end
  end

  describe 'GET #external_redirect' do
    include Docs::V0::Auth::ExternalRedirect
    context 'GET /external_redirect', :dox do
      before :each do
        request.env['HTTP_AUTHORIZATION'] = "Bearer #{@aa.current_token.to_jwt}"
      end

      it 'rejects unconfigured but valid path' do
        get :external_redirect, params: {:path => 'https://www.example.org'}
        response.code.should == '404'
      end

      it 'rejects invalid path' do
        get :external_redirect, params: {:path => ':/sdas9sd'}
        response.code.should == '400'
      end

      it 'handles basic shopify redirect' do
        get :external_redirect, params: {:path => 'http://test.myshopify.com'}
        response.code.should == '200'
      end

      it 'handles shopify checkout redirect' do
        get :external_redirect, params: {:path => 'http://test.myshopify.com?checkout_url=http%3A%2F%2Fsomecheckout.com'}
        # Actually checking the redirect requires cracking open the encrypted multipass token
        response.code.should == '200'
      end

      it 'handles zendesk redirect' do
        get :external_redirect, params: {:path => "https://#{ENV['ZENDESK_DOMAIN']}"}
        response.code.should == '200'
        JSON.parse(response.body)['redirect'].should start_with("https://#{ENV['ZENDESK_DOMAIN']}/access/jwt?jwt")
      end

      it 'handles spree redirect' do
        get :external_redirect, params: {:path => "https://spree.test.com/"}
        response.code.should == '200'
        JSON.parse(response.body)['redirect'].should start_with("https://spree.test.com/")
      end

      it 'handles chefsteps redirect' do
        redirect_base = "www.#{Rails.application.config.shared_config[:chefsteps_endpoint]}"
        token = request.env['HTTP_AUTHORIZATION']
        path = "https://#{redirect_base}/some-random-path"
        get :external_redirect, params: {:path => path}
        response.code.should == '200'
        redirect_url = JSON.parse(response.body)['redirect']
        redirect_url.should start_with("https://#{redirect_base}/sso?token=")
        uri = URI.parse(redirect_url)

        query_params = CGI.parse(uri.query)
        short_lived_token = query_params['token'][0]
        short_lived_token.should_not eq(token)
      end

      it 'handles zendesk redirect from mapped domain but still sends JWT to main domain' do
        get :external_redirect, params: {:path => "https://#{ENV['ZENDESK_MAPPED_DOMAIN']}"}
        response.code.should == '200'
        JSON.parse(response.body)['redirect'].should start_with("https://#{ENV['ZENDESK_DOMAIN']}/access/jwt?jwt")
      end

      it 'handles redirect by key' do
        Rails.configuration.redirect_by_key['made_up_test_key'] = "https://#{ENV['ZENDESK_DOMAIN']}"
        get :external_redirect_by_key, params: {:key => "made_up_test_key"}
        response.code.should == '200'
        JSON.parse(response.body)['redirect'].should start_with("https://#{ENV['ZENDESK_DOMAIN']}/access/jwt?jwt")
      end

      it 'handles shopify redirect' do
        #the controller should use the key parameter as the redirect url
        key_url = "https://#{Rails.configuration.shopify[:store_domain]}/test_url"
        get :external_redirect_by_key, params: {:key => key_url}
        response.code.should == '200'
        JSON.parse(response.body)['redirect'].should start_with("https://#{Rails.configuration.shopify[:store_domain]}/account/login/multipass")
      end

      it 'returns a proper token for amazon' do
        sign_in @user
        get :external_redirect, params: {:path => "https://pitangui.amazon.com?vendorId=12345"}
        response.code.should eq("200")

        redirect = JSON.parse(response.body)['redirect']
        uri = URI(redirect)
        uri.host.should eq("pitangui.amazon.com")

        amazon_params = redirect.split('#')[1]
        parsed_amazon_params = CGI::parse(amazon_params)
        token_string = parsed_amazon_params['access_token'][0]
        token = AuthToken.from_string token_string
        address_id = token['a']
        ActorAddress.where(address_id: address_id).first.client_metadata.should == 'amazon'
      end

      it 'returns a proper token for google' do
        sign_in @user
        get :external_redirect, params: {:path => "https://oauth-redirect.googleusercontent.com"}
        response.code.should eq("200")

        redirect = JSON.parse(response.body)['redirect']
        uri = URI(redirect)
        uri.host.should eq("oauth-redirect.googleusercontent.com")

        google_params = redirect.split('#')[1]
        parsed_google_params = CGI::parse(google_params)
        token_string = parsed_google_params['access_token'][0]
        token = AuthToken.from_string token_string
        address_id = token['a']
        ActorAddress.where(address_id: address_id).first.client_metadata.should == 'google-action'
      end

      it 'returns a proper token for facebook messenger bot' do
        sign_in @user
        get :external_redirect, params: {:path => "http://" + Rails.application.config.shared_config[:facebook][:messenger_endpoint] + "/auth?psid=1234"}

        response.code.should eq("200")

        parsed_body = JSON.parse(response.body)
        redirect = parsed_body['redirect']
        uri = URI(redirect)
        uri.host.should eq(Rails.application.config.shared_config[:facebook][:messenger_endpoint])

        fb_params = redirect.split('?')[1]
        parsed_fb_params = CGI::parse(fb_params)
        token_string = parsed_fb_params['authorization_code'][0]
        token = AuthToken.from_string token_string
        address_id = token['a']
        ActorAddress.where(address_id: address_id).first.client_metadata.should == 'facebook-messenger'
      end
    end
  end

  describe 'POST #upgrade_token' do
    include Docs::V0::Auth::UpgradeToken
    context 'POST /upgrade_token', :dox do
      before :each do
        @short_lived_token = AuthToken.provide_short_lived(@aa.current_token).to_jwt
      end

      it 'upgrades a token' do
        controller.request.env['HTTP_AUTHORIZATION'] = "Bearer #{@short_lived_token}"
        post :upgrade_token
        response.code.should eq("200")

        upgraded_token = JSON.parse(response.body)['token']
        upgraded_token.should_not eq(@short_lived_token)

        token = AuthToken.from_string upgraded_token
        token['exp'].should be_nil
        token['jti'].should be_nil
      end

      it 'can only upgrade a token once' do
        controller.request.env['HTTP_AUTHORIZATION'] = "Bearer #{@short_lived_token}"
        post :upgrade_token
        response.code.should eq("200")

        controller.request.env['HTTP_AUTHORIZATION'] = "Bearer #{@short_lived_token}"
        post :upgrade_token
        response.code.should eq("403")
      end

      it 'should return 401 unauthorized without HTTP_AUTHORIZATION' do
        post :upgrade_token
        response.code.should eq("401")
      end

    end
  end
end
