describe Api::V0::AuthController do

  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
  end

  context 'POST /authenticate' do

    it 'should return a status 400 Bad Request' do
      post :authenticate
      response.should_not be_success
      response.code.should eq("400")
    end

    it 'should return a status 401 Unauthorized if the password is incorrect' do
      post :authenticate, {user: {email: 'johndoe@chefsteps.com', password: 'abcdef'}}
      response.should_not be_success
      response.code.should eq("401")
    end

    it 'should return a token if a user is found with the correct password' do
      post :authenticate, {user: {email: 'johndoe@chefsteps.com', password: '123456'}}
      response.should be_success
      response.code.should eq("200")
      json_response = JSON.parse(response.body)
      json_response['token'].should_not be_empty
    end

  end

end