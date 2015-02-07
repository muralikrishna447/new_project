describe Api::V0::UsersController do

  context 'GET /index' do

    before :each do
      @user = Fabricate :user, id: 100, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
      key = OpenSSL::PKey::RSA.new File.read('/Users/hnguyen/Desktop/rsa.pem'), 'cooksmarter'
      issued_at = (Time.now.to_f * 1000).to_i
      claim = { 
        iat: issued_at,
        user: @user
      }
      jws = JSON::JWT.new(claim.as_json).sign(key.to_s)
      jwe = jws.encrypt(key.public_key)
      @token = 'Bearer ' + jwe.to_s
    end

    it 'should verify a token' do
      request.env['HTTP_AUTHORIZATION'] = @token
      get :index
      response.should be_success
    end

    it 'should respond with error when provided incorrect token' do
      request.env['HTTP_AUTHORIZATION'] = 'Bearer SomeBadToken'
      get :index
      response.should_not be_success
    end

    it 'should respond with error when authentication header is not properly set' do
      request.env['HTTP_AUTHORIZATION'] = ''
      get :index, auth_token: @token
      response.should_not be_success
    end

    # it 'should respond with error when token does not match user' do
    #   fake_user = {
    #     id: 101,
    #     email: 'fakejohndoe@chefsteps.com',
    #     name: 'Fake John Doe'
    #   }
    #   exp = ((Time.now + 1.year).to_f * 1000).to_i
    #   fake_payload = { 
    #     exp: exp,
    #     user: fake_user
    #   }
    #   fake_token = JWT.encode(fake_payload.as_json, "SomeSecret")

    #   request.env['HTTP_AUTHORIZATION'] = fake_token
    #   get :index
    #   response.should_not be_success
    # end

  end

end