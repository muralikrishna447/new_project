describe Api::V0::UsersController do
  before :each do
    Api::V0::BaseController.send(:public, *Api::V0::BaseController.protected_instance_methods)
    @user = Fabricate :user, id: 1, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
    exp = ((Time.now + 1.year).to_f * 1000).to_i
    payload = { 
      exp: exp,
      user: {
        id: 1,
        name: 'John Doe',
        role: 'user'
      }
    }
    @token = JWT.encode(payload.as_json, "SomeSecret")
  end
  context 'GET /index' do

    it 'should verify a token' do

      get :index, token_auth: @token
      puts response.code
      response.should be_success
    end

  end

end