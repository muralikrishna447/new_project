describe Api::V0::UsersController do

  before :each do
    @key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
    @user = Fabricate :user, id: 100, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
    issued_at = (Time.now.to_f * 1000).to_i
    claim = { 
      iat: issued_at,
      user: {
        id: @user.id,
        name: @user.name,
        email: @user.email
      }
    }
    jws = JSON::JWT.new(claim.as_json).sign(@key.to_s)
    jwe = jws.encrypt(@key.public_key)
    @token = 'Bearer ' + jwe.to_s
  end

  context 'GET /me' do
    it 'should return a users info when a valid token is provided' do
      request.env['HTTP_AUTHORIZATION'] = @token
      get :me
      puts response.body
      response.should be_success
    end

    it 'should not return a users info when a token is missing' do
      get :me
      response.should_not be_success
    end
  end

  context 'GET /index' do

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

  end

  context 'POST /create' do
    it 'should create a user' do
      post :create, user: {name: "New User", email: "newuser@chefsteps.com", password: "newUserPassword"}
      response.should be_success
    end

    it 'should not create a user if require fields are missing' do
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
      response.should be_success
      expect(JSON.parse(response.body)['token'].length).to be > 0
    end

    it 'should connect an existing Facebook user' do
      post :create, user: {name: "Existing Facebook User", email: "existingfb@user.com", password: "newUserPassword", provider: "facebook"}
      post :create, user: {name: "Existing Facebook User", email: "existingfb@user.com", password: "newUserPassword", provider: "facebook"}
      response.should be_success
      expect(JSON.parse(response.body)['token'].length).to be > 0
    end
  end

end