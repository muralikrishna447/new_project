describe Api::V0::FirmwareController do

  def mock_s3_json(key, data)
    firmware_base = "https://chefsteps-firmware-staging.s3.amazonaws.com"
    url = "#{firmware_base}/#{key}"
    WebMock.stub_request(:head, url).to_return(:status => 200, :body => "[]")
    WebMock.stub_request(:get, url).to_return(
      :status => 200, :body => data.to_json, :headers => {})
  end

  def set_version_enabled(version, is_enabled)
    BetaFeatureService.stub(:user_has_feature).with(anything(), "dfu_#{version}")
      .and_return(is_enabled)
  end


  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    @token = ActorAddress.create_for_user(@user, client_metadata: "create").current_token

    BetaFeatureService.stub(:user_has_feature).with(anything(), 'dfu')
      .and_return(true)
    BetaFeatureService.stub(:user_has_feature).with(anything(), 'esp_http_dfu')
      .and_return(false)
    BetaFeatureService.stub(:user_has_feature).with(anything(), 'dfu_blacklist')
      .and_return(false)
    enabled_app_versions = ['2.40.2', '2.41.2', '2.41.3', '2.41.4']
    for v in enabled_app_versions
      set_version_enabled(v, true)
    end

    @link = 'http://www.foo.com'
    @release_notes_url_1 = "https://www.chefsteps.com/releases/46.11"
    @release_notes = [
      'Adds a display',
      'Ability to reticulate splines',
    ]
    controller.stub(:get_firmware_link).and_return(@link)
    manifest =  {
      "releaseNotesUrl" => @release_notes_url_1,
      "releaseNotes" => @release_notes,
      "updates" => [
        {
          "versionType" => "appFirmwareVersion",
          "type" => "APPLICATION_FIRMWARE",
          "version" => "alex_latest"
        }
      ]
    }

    @esp_version = "706"
    esp_only_manifest = {
      "releaseNotesUrl" => @release_notes_url_1,
      "releaseNotes" => @release_notes,
      "updates" =>[
        {
          "versionType" => "espFirmwareVersion",
          "type" => "WIFI_FIRMWARE",
          "version" => @esp_version
        }
      ]
    }

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
    mock_s3_json("manifests/2.41.3/manifest", esp_only_manifest)
    mock_s3_json("manifests/2.41.2/manifest", esp_only_manifest)
    mock_s3_json("manifests/2.41.4/manifest", manifest)

    mock_s3_json("manifests/2.40.2/manifest", manifest)
  end

  it 'should get manifests for wifi firmware' do
    request.env['HTTP_AUTHORIZATION'] = @token.to_jwt
    post :updates, {'appVersion'=> '2.41.3', 'hardwareVersion' => 'JL.p5'}
    response.should be_success
    resp = JSON.parse(response.body)
    resp['updates'].length.should == 1
    update = resp['updates'].first

    update['type'].should == 'WIFI_FIRMWARE'
    transfer = update['transfer']
    transfer.length.should == 2

    transfer[1]['type'].should == 'http'
    transfer[1]['host'].should == Rails.application.config.firmware_download_host
    transfer[1]['sha256'].should == @sha256
    transfer[1]['filename'].should == @filename
    transfer[1]['totalBytes'].should == @totalBytes

    transfer[0]['type'].should == 'tftp'
    Rails.application.config.tftp_hosts.include?(transfer[0]['host']).should == true
    transfer[0]['sha256'].should == @sha256
    transfer[0]['filename'].should == @filename
    transfer[0]['totalBytes'].should == @totalBytes
  end

  it 'should return unauthorized if not logged in' do
    post :updates, {'appVersion'=> '2.41.3', 'hardwareVersion' => 'JL.p5'}
    response.code.should == '401'
  end

  it 'should get no updates if manifest version not enabled' do
    request.env['HTTP_AUTHORIZATION'] = @token.to_jwt
    set_version_enabled('2.41.3', false)
    post :updates, {'appVersion'=> '2.41.3', 'hardwareVersion' => 'JL.p5'}
    response.should be_success
    resp = JSON.parse(response.body)
    resp['updates'].length.should == 0
  end

  it 'should get no updates if dfu blacklisted' do
    request.env['HTTP_AUTHORIZATION'] = @token.to_jwt
    BetaFeatureService.stub(:user_has_feature).with(anything(), 'dfu_blacklist')
      .and_return(true)
    post :updates, {'appVersion'=> '2.41.3', 'hardwareVersion' => 'JL.p5'}
    response.should be_success
    resp = JSON.parse(response.body)
    resp['updates'].length.should == 0
  end

  it 'should get no updates if old app version' do
    request.env['HTTP_AUTHORIZATION'] = @token.to_jwt
    post :updates, {'appVersion'=> '2.41.0', 'hardwareVersion' => 'JL.p5'}
    response.should be_success
    resp = JSON.parse(response.body)
    resp['updates'].length.should == 0
  end

  it 'should get firmware version' do
    request.env['HTTP_AUTHORIZATION'] = @token.to_jwt

    post :updates, {'appVersion'=> '2.41.4', 'hardwareVersion' => 'JL.p5'}

    response.should be_success
    resp = JSON.parse(response.body)
    puts resp.inspect

    resp['releaseNotesUrl'].should == @release_notes_url_1
    resp['updates'].length.should == 1
    update = resp['updates'].first
    update['type'].should == 'APPLICATION_FIRMWARE'


    update['bootModeType'].should == 'APPLICATION_BOOT_MODE'
    update['transfer'].length.should == 1

    update['transfer'][0]['url'].should == @link
    update['transfer'][0]['type'].should == 'download'

  end

  it 'should not get any updates if proto4 hardware' do
    request.env['HTTP_AUTHORIZATION'] = @token.to_jwt
    post :updates, {'appVersion'=> '2.41.4', 'hardwareVersion' => 'JL.p4'}

    response.should be_success
    resp = JSON.parse(response.body)
    resp['updates'].length.should == 0
  end

  it 'should not return firmware version if up to date' do
    request.env['HTTP_AUTHORIZATION'] = @token.to_jwt
    post :updates, {'appVersion'=> '2.41.3', 'espFirmwareVersion' => @esp_version, 'hardwareVersion' => 'JL.p5'}
    response.should be_success
    resp = JSON.parse(response.body)
    resp['updates'].length.should == 0
  end

  it 'should get no updates if no manifest found' do
    WebMock.stub_request(:head, "https://chefsteps-firmware-staging.s3.amazonaws.com/manifests/0.10.0/manifest").
      to_return(:status => 404, :body => "", :headers => {})
    request.env['HTTP_AUTHORIZATION'] = @token.to_jwt
    set_version_enabled('0.10.0', true)
    post :updates, {'appVersion'=> '0.10.0', 'hardwareVersion' => 'JL.p5'}
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
