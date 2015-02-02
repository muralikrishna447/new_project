describe Api::V0::UsersController do

  context 'GET /index' do

    it 'should verify a token' do
      user = Fabricate :user, id: 100, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
      exp = ((Time.now + 1.year).to_f * 1000).to_i
      payload = { 
        exp: exp,
        user: user
      }
      token = JWT.encode(payload.as_json, "SomeSecret")

      get :index, token_auth: token
      response.should be_success
    end

    it 'should respond with error when provided incorrect token' do
      token = 'SomeBadToken'
      get :index, token_auth: token
      response.should_not be_success
    end

    it 'should respond with error when token does not match user' do
      user = Fabricate :user, id: 100, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
      fakeuser = {
        id: 101,
        email: 'fakejohndoe@chefsteps.com',
        name: 'Fake John Doe'
      }
      exp = ((Time.now + 1.year).to_f * 1000).to_i
      payload = { 
        exp: exp,
        user: fakeuser
      }
      token = JWT.encode(payload.as_json, "SomeSecret")

      get :index, token_auth: token
      response.should_not be_success
    end

  end

end