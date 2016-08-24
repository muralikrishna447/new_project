describe Api::V0::FirmwareController do

  def mock_s3_json(key, data)
    firmware_base = "https://chefsteps-firmware-staging.s3.amazonaws.com"
    url = "#{firmware_base}/#{key}"
    WebMock.stub_request(:head, url).to_return(:status => 200, :body => "[]")
    WebMock.stub_request(:get, url).to_return(
      :status => 200, :body => data.to_json, :headers => {})
  end

  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    @token = ActorAddress.create_for_user(@user, client_metadata: "create").current_token

    BetaFeatureService.stub(:user_has_feature).with(anything(), 'dfu')
      .and_return(true)
    BetaFeatureService.stub(:user_has_feature).with(anything(), 'esp_http_dfu')
      .and_return(false)

    @link = 'http://www.foo.com'
    controller.stub(:get_firmware_link).and_return(@link)
    manifest = [{
      "versionType" => "appFirmwareVersion",
      "type" => "APPLICATION_FIRMWARE",
      "version" => "alex_latest" }]

    @esp_version = "706"
    esp_only_manifest = [
      {
        "versionType" => "espFirmwareVersion",
        "type" => "WIFI_FIRMWARE",
        "version" => @esp_version
      }
    ]

    @sha256 = "4a241f2e5bade1cceaa082acb5249497d23ff1b1882badc6cfdb82d6d1c0bcac"
    @filename = "#{@esp_version}.bin"
    esp_metadata = {
      "sha256" => @sha256,
      "filename" => @filename,
      "totalBytes" => @totalBytes,
    }
    mock_s3_json(
      "joule/WIFI_FIRMWARE/#{@esp_version}/metadata.json", esp_metadata
    )
    mock_s3_json("manifests/0.19.0/manifest", esp_only_manifest)
    mock_s3_json("manifests/0.18.0/manifest", manifest)
  end

  it 'should get manifests for wifi firmware' do
    request.env['HTTP_AUTHORIZATION'] = @token.to_jwt
    post :updates, {'appVersion'=> '0.19.0'}
    response.should be_success
    resp = JSON.parse(response.body)
    resp['updates'].length.should == 1
    update = resp['updates'].first

    update['type'].should == 'WIFI_FIRMWARE'
    transfer = update['transfer']
    transfer['type'].should == 'tftp'
    Rails.application.config.tftp_hosts.include?(transfer['host']).should == true
    transfer['sha256'].should == @sha256
    transfer['filename'].should == @filename
    transfer['totalBytes'].should == @totalBytes
  end

  it 'should get no updates if not beta user' do
    request.env['HTTP_AUTHORIZATION'] = @token.to_jwt
    BetaFeatureService.stub(:user_has_feature).and_return(false)
    post :updates, {'appVersion'=> '0.19.0'}
    response.should be_success
    resp = JSON.parse(response.body)
    resp['updates'].length.should == 0
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

    # TODO: remove this check after breaking-change day
    update['location'].should == @link

    update['transfer']['url'].should == @link
    update['transfer']['type'].should == 'download'

  end

  it 'should not return firmware version if up to date' do
    request.env['HTTP_AUTHORIZATION'] = @token.to_jwt
    post :updates, {'appVersion'=> '0.19.0', 'espFirmwareVersion' => @esp_version}
    response.should be_success
    resp = JSON.parse(response.body)
    resp['updates'].length.should == 0
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

  it 'should get HTTP transfer type for wifi firmware if enabled' do
    BetaFeatureService.stub(:user_has_feature).with(anything(), 'esp_http_dfu')
      .and_return(true)
    request.env['HTTP_AUTHORIZATION'] = @token.to_jwt
    post :updates, {'appVersion'=> '0.19.0'}
    response.should be_success
    resp = JSON.parse(response.body)
    resp['updates'].length.should == 1
    update = resp['updates'].first

    update['type'].should == 'WIFI_FIRMWARE'
    transfer = update['transfer']
    transfer['type'].should == 'http'
    transfer['host'].should == Rails.application.config.firmware_download_host
    transfer['sha256'].should == @sha256
    transfer['sha256'].should == @sha256
    transfer['filename'].should == @filename
    transfer['totalBytes'].should == @totalBytes
  end
end
