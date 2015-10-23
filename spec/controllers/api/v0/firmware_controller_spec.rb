describe Api::V0::FirmwareController do
  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    @token = ActorAddress.create_for_user(@user, client_metadata: "create").current_token
  end

  it 'should list circulators' do
    request.env['HTTP_AUTHORIZATION'] = @token.to_jwt
    get :latest_version
    response.should be_success
  end
end
