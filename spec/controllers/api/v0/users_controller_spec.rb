describe Api::V0::UsersController do

  context 'GET /index' do

    before :each do
      @user = Fabricate :user, id: 100, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
      exp = ((Time.now + 1.year).to_f * 1000).to_i
      payload = { 
        exp: exp,
        user: @user
      }
      @token = JWT.encode(payload.as_json, "SomeSecret")
    end

    it 'should verify a token' do
      request.env['HTTP_AUTHORIZATION'] = @token
      get :index
      response.should be_success
    end

    it 'should respond with error when provided incorrect token' do
      request.env['HTTP_AUTHORIZATION'] = 'SomeBadToken'
      get :index
      response.should_not be_success
    end

    it 'should respond with error when authentication header is not properly set' do
      request.env['HTTP_AUTHORIZATION'] = ''
      get :index, token_auth: @token
      response.should_not be_success
    end

    it 'should respond with error when token does not match user' do
      fake_user = {
        id: 101,
        email: 'fakejohndoe@chefsteps.com',
        name: 'Fake John Doe'
      }
      exp = ((Time.now + 1.year).to_f * 1000).to_i
      fake_payload = { 
        exp: exp,
        user: fake_user
      }
      fake_token = JWT.encode(fake_payload.as_json, "SomeSecret")

      request.env['HTTP_AUTHORIZATION'] = fake_token
      get :index
      response.should_not be_success
    end

  end

end