require 'spec_helper'

describe Api::V0::UsersController do
  include Docs::V0::Users::Api

  before :each do
    @user = Fabricate :user, id: 100, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
    @aa = ActorAddress.create_for_user @user, client_metadata: "test"
    @token = 'Bearer ' + @aa.current_token.to_jwt
    BetaFeatureService.stub(:user_has_feature).with(@user, anything, anything)\
      .and_return(false)

    @other_user = Fabricate :user, id: 101, email: 'janedoe@chefsteps.com', password: '123456', name: 'Jane Doe', role: 'user'
    @other_aa = ActorAddress.create_for_user @other_user, client_metadata: "test"
    @other_token = 'Bearer ' + @other_aa.current_token.to_jwt
    BetaFeatureService.stub(:user_has_feature).with(@other_user, anything, anything)\
      .and_return(false)

    BetaFeatureService.stub(:get_groups_for_user).with(anything)
      .and_return([])

    issued_at = (Time.now.to_f * 1000).to_i
    service_claim = {
      iat: issued_at,
      service: 'CSSpree'
    }
    @key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
    @service_token = JSON::JWT.new(service_claim.as_json).sign(@key.to_s).to_s
  end

  describe 'GET #me' do
    include Docs::V0::Users::Me
    context 'GET /me', :dox do
      it 'should return a users info when a valid token is provided' do
        request.env['HTTP_AUTHORIZATION'] = @token

        get :me

        response.code.should == "200"
        result = JSON.parse(response.body)

        result.delete('id').should == @user.id
        result.delete('name').should == @user.name
        result.delete('email').should == @user.email
        result.delete('slug').should == @user.slug
        result.delete('avatar_url').should == @user.avatar_url
        result.delete('needs_special_terms').should == @user.needs_special_terms
        result.delete('encrypted_bloom_info')

        result.delete('request_id')
        result.delete('plan_type').should == nil
        result.delete('premium').should == false
        result.delete('studio').should == false
        result.delete('used_circulator_discount').should == false
        result.delete('admin').should == false
        result.delete('joule_purchase_count').should == 0
        result.delete('referral_code').should == nil
        result.delete('capabilities').should == []
        result.delete('settings').should == nil
        result.delete('subscriptions').should == []
        result.delete('is_consent_displayed').should == false
        result.empty?.should == true
      end

      it 'should return saved settings as settings when a valid token is provided, with data' do
        request.env['HTTP_AUTHORIZATION'] = @token

        @user.create_settings!({
                                :locale => 'en-US',
                                :preferred_temperature_unit => 'c',
                                :country_iso2 => 'GB'
                              })

        get :me

        response.code.should == "200"
        result = JSON.parse(response.body)

        result.delete('id').should == @user.id
        result.delete('name').should == @user.name
        result.delete('email').should == @user.email
        result.delete('slug').should == @user.slug
        result.delete('avatar_url').should == @user.avatar_url
        result.delete('needs_special_terms').should == @user.needs_special_terms
        result.delete('encrypted_bloom_info')

        result.delete('request_id')
        result.delete('plan_type').should == nil
        result.delete('premium').should == false
        result.delete('studio').should == false
        result.delete('used_circulator_discount').should == false
        result.delete('admin').should == false
        result.delete('joule_purchase_count').should == 0
        result.delete('referral_code').should == nil
        result.delete('capabilities').should == []
        result['settings'].delete('locale').should == 'en-US'
        result['settings'].delete('has_viewed_turbo_intro').should == nil
        result['settings'].delete('preferred_temperature_unit').should == 'c'
        result['settings'].delete('has_purchased_truffle_sauce').should == nil
        result['settings'].delete('country_iso2').should == 'GB'
        result.delete('settings').should == {}
        result.delete('subscriptions').should == []
        result.delete('is_consent_displayed').should == false
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

      context 'user has beta_guides capability' do
        before :each do
          Rails.cache.clear()
        end

        it 'returns beta_guides capability' do
          request.env['HTTP_AUTHORIZATION'] = @token
          BetaFeatureService.stub(:user_has_feature).with(@user, 'beta_guides', anything)
            .and_return(true)

          get :me

          response.code.should == "200"
          result = JSON.parse(response.body)
          result['capabilities'].should == ['beta_guides']
        end
      end

    end
  end

  describe 'POST #create' do
    include Docs::V0::Users::Create
    context 'POST /create', :dox do
      it 'should create a user' do
        Resque.should_receive(:enqueue).with(Forum, "initial_user", "bloomAPI", kind_of(Numeric))
        Resque.should_receive(:enqueue).with(UserSync, kind_of(Numeric))
        Resque.should_receive(:enqueue).with(EmployeeAccountProcessor, kind_of(Numeric))
        post :create, params: {user: {name: "New User", email: "newuser@chefsteps.com", password: "newUserPassword"}}
        response.should be_success
      end

      it 'should call email signup' do
        Api::BaseController.any_instance.should_receive(:email_list_signup)
        post :create, params: {user: {name: "New User", email: "newuser@chefsteps.com", password: "newUserPassword", opt_in: 'true'}}
        response.should be_success
      end

      it 'should create user with is_consent_displayed as true' do
        Api::BaseController.any_instance.should_receive(:email_list_signup)
        post :create, params: {user: {name: "New User", email: "newuser@chefsteps.com", password: "newUserPassword", opt_in: 'true'}}
        expect(User.find_by_email('newuser@chefsteps.com').is_consent_displayed).to eq(true)
        response.should be_success
      end

      it 'should not call email signup if the user opts out' do
        Api::BaseController.any_instance.should_not_receive(:email_list_signup)
        post :create, params: {optout: "true", user: {name: "New User", email: "newuser@chefsteps.com", password: "newUserPassword"}}
        response.should be_success
      end

      it 'should not create a user if required fields are missing' do
        post :create, params: {user: {email: "newuser@chefsteps.com", password: "newUserPassword"}}
        response.should_not be_success
      end

      it 'should respond with an error if user already exists' do
        post :create, params: {user: {name: "New User", email: "newuser@chefsteps.com", password: "newUserPassword"}}
        post :create, params: {user: {name: "Another New User", email: "newuser@chefsteps.com", password: "newUserPassword"}}
        response.should_not be_success
      end

      it 'should create a new Facebook user' do
        post :create, params: {user: {name: "New Facebook User", email: "newfb@user.com", password: "newUserPassword", provider: "facebook"}}
        response.code.should == "403"
      end

      it 'should connect an existing Facebook user' do
        post :create, params: {user: {name: "Existing Facebook User", email: "existingfb@user.com", password: "newUserPassword", provider: "facebook"}}
        response.code.should == "403"
        post :create, params: {user: {name: "Existing Facebook User", email: "existingfb@user.com", password: "newUserPassword", provider: "facebook"}}
        response.code.should == "403"
      end

      it 'should create a user acquisition object' do
        request.cookies['utm'] = {referrer: 'http://u.ca', utm_campaign: '54-40'}.to_json
        post :create, params: {user: {name: 'Acquired User', email: 'a@u.ca', password: 'tricksy'}}

        ua = UserAcquisition.where(utm_campaign: '54-40')
        expect(ua.count).to eq(1)
        expect(ua.first.referrer).to eq('http://u.ca')
      end
    end
  end

  context 'POST /international_joule' do
    it "should add the user to mailchimp" do
      skip "Gotta figure out the mailchimp stuff"
    end
  end

  describe 'POST #make_premium' do
    include Docs::V0::Users::MakePremium
    context 'POST /make_premium', :dox do
      it "makes a valid user premium" do
        #the user is first NOT premium
        request.env['HTTP_AUTHORIZATION'] = @token
        get :me
        response.code.should == "200"
        user_info = JSON.parse(response.body)
        expect(user_info["premium"]).to be false

        #make the user premium
        request.env['HTTP_AUTHORIZATION'] = @service_token
        post :make_premium, params: {id: 100, price: 29}
        response.code.should == "200"

        #the user should now be premium
        request.env['HTTP_AUTHORIZATION'] = @token
        get :me
        response.code.should == "200"
        user_info = JSON.parse(response.body)
        expect(user_info["premium"]).to be true
      end

      it "fails when arguments are omitted" do
        request.env['HTTP_AUTHORIZATION'] = @service_token
        post :make_premium, params: {price: 29}
        response.code.should == "400"

        request.env['HTTP_AUTHORIZATION'] = @service_token
        post :make_premium, params: {id: 100}
        response.code.should == "400"
      end
    end
  end

  describe 'PUT #update' do
    include Docs::V0::Users::Update
    context 'PUT /update', :dox do
      it 'should update a user' do
        request.env['HTTP_AUTHORIZATION'] = @token
        put :update, params: {id: 100, user: {name: 'Joseph Doe', email: 'mynewemail@user.com'}}
        response.should be_success
        parsed = JSON.parse(response.body)
        expect(parsed['name']).to eq('Joseph Doe')
        expect(parsed['email']).to eq('mynewemail@user.com')
      end

      it 'should not update a user without a valid token' do
        put :update, params: {id: 100, params: {user: {name: 'Joseph Doe', email: 'mynewemail@user.com'}}}
        response.should_not be_success
      end

      it 'should not update a user if token belongs to another user' do
        @another_user = Fabricate :user, id: 105, email: 'jojosmith@chefsteps.com', password: '123456', name: 'Jo Jo smith', role: 'user'
        aa = ActorAddress.create_for_user @another_user, client_metadata: "test"
        another_token = 'Bearer ' + aa.current_token.to_jwt
        request.env['HTTP_AUTHORIZATION'] = another_token
        put :update, params: {id: 100, user: {name: 'Joseph Doe', email: 'mynewemail@user.com'}}
        response.should_not be_success
      end
    end
  end

  describe 'GET #log_upload_url' do
    include Docs::V0::Users::LogUploadUrl
    context 'GET /log_upload_url', :dox do
      it 'should generate an upload url with valid auth token' do
        request.env['HTTP_AUTHORIZATION'] = @token
        get :log_upload_url
        response.should be_success
        JSON.parse(response.body)['upload_url'].should_not be_nil
      end

      it 'should accept invalid auth token' do
        request.env['HTTP_AUTHORIZATION'] = @token + 'gibberish'
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
  end

  describe 'GET #capabilities' do
    include Docs::V0::Users::Capabilities
    context 'GET /capabilities', :dox do
      before :each do
        Rails.cache.clear()
      end

      it 'get empty list if no capabilities' do
        request.env['HTTP_AUTHORIZATION'] = @token
        get :capabilities
        response.should be_success
      end

      it 'get beta_guides capability' do
        request.env['HTTP_AUTHORIZATION'] = @token
        BetaFeatureService.stub(:user_has_feature).with(@user, 'beta_guides', anything)
          .and_return(true)
        get :capabilities
        response.should be_success
        JSON.parse(response.body)['capabilities'].should == ['beta_guides']
      end

      it 'get capabilities for two users' do
        request.env['HTTP_AUTHORIZATION'] = @token
        BetaFeatureService.stub(:user_has_feature).with(@user, 'beta_guides', anything)
          .and_return(true)

        get :capabilities
        response.should be_success
        JSON.parse(response.body)['capabilities'].should == ['beta_guides']

        request.env['HTTP_AUTHORIZATION'] = @other_token
        get :capabilities
        response.should be_success
        JSON.parse(response.body)['capabilities'].should == []
      end

      it 'get return error if not logged in' do
        get :capabilities
        response.code.should == '401'
      end
    end
  end

  describe 'POST #update_settings' do
    include Docs::V0::Users::UpdateSettings
    context '#update_settings :user_id (from Spree)', :dox do
      it "notes the truffle sauce purchase" do
        #the user is first NOT premium
        request.env['HTTP_AUTHORIZATION'] = @token
        get :me
        response.code.should == "200"
        user_info = JSON.parse(response.body)
        settings  = user_info["settings"] || {}
        expect(settings["has_purchased_truffle_sauce"]).to be_nil

        #set the truffle setting
        request.env['HTTP_AUTHORIZATION'] = @service_token
        post :update_settings, params: {id: 100, settings: {:has_purchased_truffle_sauce => true}}
        response.code.should == "200"

        #the user should now have truffle
        request.env['HTTP_AUTHORIZATION'] = @token
        get :me
        response.code.should == "200"
        user_info = JSON.parse(response.body)
        settings  = user_info["settings"] || {}
        expect(settings["has_purchased_truffle_sauce"]).to be true
      end

      it "fails when a user token is used" do
        request.env['HTTP_AUTHORIZATION'] = @token
        post :update_settings, params: {id: 100, settings: {:has_purchased_truffle_sauce => true}}
        response.code.should == "403"
      end
    end
  end

  describe 'POST #update_my_settings' do
    include Docs::V0::Users::UpdateMySettings
    context '#update_my_settings', :dox do
      it 'should return default settings info when a valid token is provided, with no data' do
        request.env['HTTP_AUTHORIZATION'] = @token

        post :update_my_settings

        response.code.should == "200"
        result = JSON.parse(response.body)

        result.delete('locale').should == nil
        result.delete('has_viewed_turbo_intro').should == nil
        result.delete('preferred_temperature_unit').should == nil
        result.delete('has_purchased_truffle_sauce').should == nil
        result.delete('country_iso2').should == nil

        result.empty?.should == true
      end

      it 'should return saved settings info when a valid token is provided, with data' do
        request.env['HTTP_AUTHORIZATION'] = @token

        @user.create_settings!(preferred_temperature_unit: 'c')

        expect {
          post :update_my_settings, params: {:settings => {
              :has_viewed_turbo_intro => true,
              :preferred_temperature_unit => 'f',
              :country_iso2 => 'CA'
          }}
        }.to change {
          @user.settings.reload.preferred_temperature_unit
        }.from('c').to('f')

        response.code.should == "200"
        result = JSON.parse(response.body)

        result.delete('locale').should == nil
        result.delete('has_viewed_turbo_intro').should == true
        result.delete('preferred_temperature_unit').should == 'f'
        result.delete('has_purchased_truffle_sauce').should == nil
        result.delete('country_iso2').should == 'CA'

        result.empty?.should == true
      end

      it 'should return saved settings info when a valid token is provided, with data' do
        request.env['HTTP_AUTHORIZATION'] = @token

        expect {
          post :update_my_settings, params: {:settings => {
              :preferred_temperature_unit => 'x'
          }}
        }.to_not change {
          @user.reload.settings
        }

        response.code.should == "400"
        result = JSON.parse(response.body)
        result['errors'].should == {'preferred_temperature_unit' => ['is not included in the list']}

      end

      it 'should not work when a token is missing' do
        post :update_my_settings, params: {:settings => {
            :has_viewed_turbo_intro => true,
            :preferred_temperature_unit => 'f',
            :country_iso2 => 'CA'
        }}
        response.code.should == "401"
      end
    end
  end

  describe 'POST #update_user_consent' do
    include Docs::V0::Users::UpdateUserConsent
    context '#update_user_consent', :dox do
      before :each do
        @user = Fabricate :user, id: 200, email: 'test-api@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
      end

      it 'should update user opt_in as true and is_consent_displayed true' do
        sign_in @user
        Api::BaseController.any_instance.should_receive(:email_list_signup)
        post :update_user_consent, params: {user: {opt_in: true, is_consent_displayed: true}}

        response.should be_success
      end

      it 'should call email_list_signup if opt_in is true' do
        sign_in @user
        Api::BaseController.any_instance.should_receive(:email_list_signup)
        post :update_user_consent, params: {user: {opt_in: true, is_consent_displayed: true}}

        response.should be_success
        user = User.find(200)
        expect(user.opt_in).to eq(true)
        expect(user.is_consent_displayed).to eq(true)
      end

      it 'should take the country code from cookie' do
        sign_in @user
        request.cookies['cs_geo'] = {country: 'IN'}.to_json
        post :update_user_consent, params: {user: {opt_in: true, is_consent_displayed: true}}

        response.should be_success
        user = User.find(200)
        expect(user.country_code).to eq('IN')
      end

      it 'should update only opt_in as true' do
        sign_in @user
        post :update_user_consent, params: {user: {opt_in: true}}

        response.should be_success
        user = User.find(200)
        expect(user.opt_in).to eq(true)
      end

      it 'should update only opt_in as false' do
        sign_in @user
        post :update_user_consent, params: {user: {opt_in: false}}

        response.should be_success
        user = User.find(200)
        expect(user.opt_in).to eq(false)
      end

      it 'should not allow params other than opt_in is_consent_displayed' do
        sign_in @user
        Api::BaseController.any_instance.should_receive(:email_list_signup)
        post :update_user_consent, params: {user: {opt_in: true, is_consent_displayed: true, not_valid: false}}

        response.should be_success
      end
    end
  end

  describe 'POST #mailchimp_webhook' do
    include Docs::V0::Users::MailchimpWebhook
    context 'mailchimp webhook', :dox do
      it 'should receive success response if head request' do
        head :mailchimp_webhook

        response.should be_success
      end

      it 'should not allow invalid params' do
        post :mailchimp_webhook, params: {}

        response.should_not be_success
        expect(response.status).to eq(400)
      end

      it 'should not allow invalid email id' do
        post :mailchimp_webhook, params: {type: 'subscribed', data: {email: 'invalid@mail.com'}}

        response.should_not be_success
        expect(response.status).to eq(400)
      end
    end
  end
end
