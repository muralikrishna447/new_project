describe Api::Admin::UsersController do

  before :each do
    @user_1 = Fabricate :user, name: 'Test User', email: 'test@user_1.com', role: 'user'
    @circulator_1 = Fabricate :circulator, serial_number: 'circ123', circulator_id: '123'
    @circulator_user_1 = Fabricate :circulator_user, circulator_id: @circulator_1.id, user_id: @user_1.id
    @actor_address_1 = Fabricate :actor_address, actor_id: @user_1.id, actor_type: 'User'

    @user2 = Fabricate :user, name: 'Test User 2', email: 'test2@user_1.com', role: 'user'
  end

  context 'unauthenticated admin user' do
    # GET /api/admin/users/:id
    it 'should not authorize request' do
      get :show, id: @user_1.id
      response.should_not be_success
    end

    it 'should not authorize request for circulators' do
      get :circulators, id: @user_1.id
      response.should_not be_success
    end
  end

  context 'not admin but authorized service' do
    before :each do
      issued_at = (Time.now.to_f * 1000).to_i
      service_claim = {
        iat: issued_at,
        service: 'Messaging' # TODO: this is the wrong service here
      }
      @key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
      @service_token = JSON::JWT.new(service_claim.as_json).sign(@key.to_s).to_s
      request.env['HTTP_AUTHORIZATION'] = @service_token
    end

    it 'should authorize' do
      get :circulators, id: @user_1.id
      response.should be_success
    end
  end

  context 'authenticated admin user' do
    before :each do
      @admin_user = Fabricate :user, name: 'Admin User', email: 'admin@chefsteps.com', role: 'admin'
      sign_in @admin_user
      controller.request.env['HTTP_AUTHORIZATION'] = @admin_user.valid_website_auth_token.to_jwt
    end

    # GET /api/admin/users/:id
    it 'should get a user' do
      get :show, id: @user_1.id
      response.should be_success
    end

    # GET /api/admin/users?email=:email
    it 'should get a user' do
      get :index, {email: @user_1.email}
      response.should be_success
      users = JSON.parse(response.body)
      users.length.should eq(1)
      users[0]['name'].should eq('Test User')
    end

    it 'should return a users circulators' do
      get :circulators, id: @user_1.id
      response.should be_success
      circulators = JSON.parse(response.body)
      circulators.length.should eq(1)
      circulators[0]['serialNumber'].should eq(@circulator_1.serial_number)
    end

    it 'should return a users actor_addresses' do
      get :actor_addresses, id: @user_1.id
      response.should be_success
      actor_addresses = JSON.parse(response.body)
      actor_addresses.length.should eq(1)
    end
  end

end
