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

    describe 'token' do
      
      before :each do
        post :authenticate, {user: {email: 'johndoe@chefsteps.com', password: '123456'}}
        response.should be_success
        response.code.should eq("200")
        @json_response = JSON.parse(response.body)
      end

      it 'should be returned' do
        @json_response['token'].should_not be_empty
        puts response.body
      end

      it 'should be authenticatable with a valid secret' do
        token = @json_response['token']
        token.should_not be_empty
        decoded = JWT.decode(token, "SomeSecret")
        name = decoded['user']['name']
        name.should eq(@user.name)
      end

    end

  end

end