describe Api::V0::AuthController do

  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    @key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
  end

  context 'POST /authenticate' do

    it 'should return a status 400 Bad Request' do
      post :authenticate
      response.should_not be_success
      response.code.should eq("400")
    end

    it 'should return a status 401 Unauthorized if the password is incorrect' do
      post :authenticate, user: {email: 'johndoe@chefsteps.com', password: 'abcdef'}
      response.should_not be_success
      response.code.should eq("401")
    end

    describe 'token' do
      
      before :each do
        post :authenticate, user: {email: 'johndoe@chefsteps.com', password: '123456'}
        response.should be_success
        response.code.should eq("200")
        @token = JSON.parse(response.body)['token']
        
      end

      it 'should be returned' do
        @token.should_not be_empty
      end

      it 'should be authenticatable with a valid secret' do
        # First decode encryption
        decoded = JSON::JWT.decode(@token, @key)
        # puts "Decoded: #{decoded}"

        # Then decode signature
        verified = JSON::JWT.decode(decoded.to_s, @key.to_s)
        # puts "Verified: #{verified}"
        id = verified['user']['id']
        id.should eq(@user.id)
      end

    end

  end

  context 'POST /validate' do
    before :each do
      @user = Fabricate :user, id: 200, email: 'user@chefsteps.com', password: '123456', name: 'A User', role: 'user'
      issued_at = (Time.now.to_f * 1000).to_i
      claim = { 
        iat: issued_at,
        user: @user
      }
      jws = JSON::JWT.new(claim.as_json).sign(@key.to_s)
      jwe = jws.encrypt(@key.public_key)
      @valid_token = 'Bearer ' + jwe.to_s
      @invalid_token = 'Bearer Some Bad Token'
    end

    it 'should validate a valid token' do
      request.env['HTTP_AUTHORIZATION'] = @valid_token
      post :validate
      response.should be_success
      puts response.body
      expect(JSON.parse(response.body)['tokenValid']).to be_true
    end

    it 'should not validate an invalid token' do
      request.env['HTTP_AUTHORIZATION'] = @invalid_token
      post :validate
      response.should_not be_success
      puts response.body
      expect(JSON.parse(response.body)['tokenValid']).to be_false
    end
  end

end