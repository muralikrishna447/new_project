describe Api::V0::FirmwareController do
  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    @token = ActorAddress.create_for_user(@user, client_metadata: "create").current_token
  end

  it 'should get firmware version' do
    request.env['HTTP_AUTHORIZATION'] = @token.to_jwt
    get :latest_version
    response.should be_success
    resp = JSON.parse(response.body)
    resp['version'].should_not be_nil
    resp['location'].should_not be_nil
  end

  it 'should get firmware version if not logged in' do
    get :latest_version
    response.should be_success
    resp = JSON.parse(response.body)
    resp['version'].should_not be_nil
    resp['location'].should_not be_nil
  end
  it 'should fail if bad token' do
    request.env['HTTP_AUTHORIZATION'] = 'fooooooo'
    get :latest_version
    response.should_not be_success
  end
end
