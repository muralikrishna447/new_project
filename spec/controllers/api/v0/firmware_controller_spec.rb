describe Api::V0::FirmwareController do
  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    @token = ActorAddress.create_for_user(@user, client_metadata: "create").current_token

    @link = 'http://www.foo.com'
    controller.stub(:get_firmware_link).and_return(@link)
    
    WebMock.stub_request(:head, "https://chefsteps-firmware-staging.s3.amazonaws.com/manifests/0.18.0/manifest").
      to_return(:status => 200, :body => "[]")
      
    manifest = [{
      "versionType" => "appFirmwareVersion",
      "type" => "APPLICATION_FIRMWARE",
      "version" => "alex_latest" }]

    WebMock.stub_request(:get, "https://chefsteps-firmware-staging.s3.amazonaws.com/manifests/0.18.0/manifest").
      to_return(:status => 200, :body => manifest.to_json, :headers => {})
  end

  it 'should get firmware version' do
    request.env['HTTP_AUTHORIZATION'] = @token.to_jwt
      
    post :updates, {'appVersion'=> '0.18.0'}
        
    response.should be_success
    resp = JSON.parse(response.body)
    puts resp.inspect
    resp['updates'].length.should == 1
    update = resp['updates'].first
    update['type'].should == 'APPLICATION_FIRMWARE'
    update['location'].should == @link
    
  end

  it 'should get no updates if no manifest found' do
    WebMock.stub_request(:head, "https://chefsteps-firmware-staging.s3.amazonaws.com/manifests/0.10.0/manifest").
      to_return(:status => 404, :body => "", :headers => {})
    post :updates, {'appVersion'=> '0.10.0'}
    puts response.code
    response.should be_success
    resp = JSON.parse(response.body)
    resp['updates'].should be_empty
  end

  it 'should fail if bad token' do
    request.env['HTTP_AUTHORIZATION'] = 'fooooooo'
    post :updates
    response.should_not be_success
  end
end
