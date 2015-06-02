describe Api::V0::AuthController do

  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    @other_user = Fabricate :user, email: 'jane@chefsteps.com', password: 'matter', name: 'Jane'
    @key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
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
      response.code.should eq("401")
    end

    it 'should persist client metadata' do
      post :authenticate, user: {email: 'johndoe@chefsteps.com', password: '123456'}, client_metadata: "cooking_app"
      token = AuthToken.from_string JSON.parse(response.body)['token']
      address_id = token['address_id']
      ActorAddress.where(address_id: address_id).first.client_metadata.should == 'cooking_app'
    end

    it 'should re-use an existing address' do
      aa = ActorAddress.create_for_user @user, "cooking_app"
      aa.current_token
      post :authenticate, user: {email: 'johndoe@chefsteps.com', password: '123456'},
        token: aa.current_token.only_signed
      token = JSON.parse(response.body)['token']

      decoded = JSON.parse(UrlSafeBase64.decode64(token.split('.')[1]))

      decoded['address_id'].should == aa.address_id
      decoded['seq'].should == (aa.sequence + 2)
    end

    it 'should reject mismatched token' do
      aa = ActorAddress.create_for_user @other_user, "cooking_app"
      aa.current_token
      post :authenticate, user: {email: 'johndoe@chefsteps.com', password: '123456'},
        token: aa.current_token.only_signed

      response.should_not be_success
      response.code.should eq("401")
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
        # First decode encryption
        #puts @token, @token.inspect
        verified = JSON::JWT.decode(@token, @key.to_s)
        #puts "Decoded: #{verified.inspect}"

        # Then decode signature
        #verified = JSON::JWT.decode(decoded.to_s, @key.to_s)
        # puts "Verified: #{verified}"
        id = verified['User']['id']
        id.should eq(@user.id)
        # TODO - get a new address
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
      @service_token = JSON::JWT.new(service_claim.as_json).sign(@key.to_s).encrypt(@key.public_key).to_s

      @user = Fabricate :user, id: 200, email: 'user@chefsteps.com', password: '123456', name: 'A User', role: 'user'
      claim = {
        iat: issued_at,
        user: @user
      }
      jws = JSON::JWT.new(claim.as_json).sign(@key.to_s)
      jwe = jws.encrypt(@key.public_key)
      @valid_token = jwe.to_s
      @invalid_token = 'Bearer Some Bad Token'
    end

    it 'should validate if provided a valid service token' do
      request.env['HTTP_AUTHORIZATION'] = @service_token
      get :validate, token: @valid_token
      response.should be_success
      expect(JSON.parse(response.body)['tokenValid']).to be_true
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
end
