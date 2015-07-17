describe Api::V0::UsersController do

  before :each do
    @user = Fabricate :user, id: 100, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
    aa = ActorAddress.create_for_user @user, client_metadata: "test"
    @token = 'Bearer ' + aa.current_token.to_jwt
  end

  context 'GET /me' do
    it 'should return a users info when a valid token is provided' do
      request.env['HTTP_AUTHORIZATION'] = @token
      get :me
      result = JSON.parse(response.body)
      # TODO - write a nice utility for this sort of comparison
      result.delete('id').should == @user.id
      result.delete('name').should == @user.name
      result.delete('email').should == @user.email
      result.delete('slug').should == @user.slug
      result.delete('avatar_url').should == @user.avatar_url
      result.delete('intercom_user_hash').should == ApplicationController.new.intercom_user_hash(@user)
      result.empty?.should == true

      response.should be_success
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

  context 'PUT /update' do
    it 'should update a user' do
      request.env['HTTP_AUTHORIZATION'] = @token
      put :update, id: 100, user: {name: 'Joseph Doe', email: 'mynewemail@user.com' }
      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['name']).to eq('Joseph Doe')
      expect(parsed['email']).to eq('mynewemail@user.com')
    end

    it 'should not update a user without a valid token' do
      put :update, id: 100, user: {name: 'Joseph Doe', email: 'mynewemail@user.com' }
      response.should_not be_success
    end

    it 'should not update a user if token belongs to another user' do
      @another_user = Fabricate :user, id: 105, email: 'jojosmith@chefsteps.com', password: '123456', name: 'Jo Jo smith', role: 'user'
      aa = ActorAddress.create_for_user @another_user, client_metadata: "test"
      another_token = 'Bearer ' + aa.current_token.to_jwt
      request.env['HTTP_AUTHORIZATION'] = another_token
      put :update, id: 100, user: {name: 'Joseph Doe', email: 'mynewemail@user.com' }
      response.should_not be_success
    end
  end
end
