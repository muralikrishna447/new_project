describe Api::V0::CirculatorsController do
  before :each do
    @user = Fabricate :user, id: 12345, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
    @circulator = Fabricate :circulator, notes: 'some notes', circulator_id: '1212121212121212', name: 'my name'
    @admin_user = Fabricate :user, email: 'admin@chefsteps.com', password: '123456', name: 'John Doe', role: 'admin'

    @aa = ActorAddress.create_for_circulator @circulator
    @other_circulator = Fabricate :circulator, notes: 'some other notes', circulator_id: '4545454545454545'
    @circulator_user = Fabricate :circulator_user, user: @user, circulator: @circulator, owner: true

    @user_aa = ActorAddress.create_for_user(@user, client_metadata: "create")
    token = @user_aa.current_token
    request.env['HTTP_AUTHORIZATION'] = token.to_jwt
  end

  after :each do
    Timecop.return
  end

  it 'should list circulators' do
    get :index

    response.should be_success
    circulators = JSON.parse(response.body)
    circulators.length.should == 1
    circulators[0]['circulatorId'].should == @circulator.circulator_id
    circulators[0]['notes'].should == 'some notes'
    circulators[0]['secretKey'].should == nil
    circulators[0]['name'].should == 'my name'
  end

  it 'should create circulator' do
    secret_key = '6b714257175f73150228454466307d16'
    serial_number = 'abc123'
    notes = 'red one'
    name = 'my name is my name'

    now = nil
    # https://github.com/travisjeffery/timecop/issues/176
    Timecop.freeze(Time.zone.now.change(nsec: 0)) do
      post(:create,
           circulator: {
             :serial_number => serial_number,
             :notes => notes,
             :name => name,
             :id => '7878787878787878',
             :secret_key => secret_key
           }
      )
      now = Time.now
    end
    response.should be_success
    returnedCirculator = JSON.parse(response.body)

    returnedCirculator['secretKey'].should == secret_key
    returnedCirculator['serialNumber'].should == serial_number
    returnedCirculator['notes'].should == notes
    returnedCirculator['name'].should == name
    returnedCirculator['lastAccessedAt'].should == now.utc.iso8601
    circulator = Circulator.where(circulator_id: returnedCirculator['circulatorId']).first
    circulator.should_not be_nil
    circulator.notes.should == notes
    circulator.name.should == name
    circulator.users.first.should == @user
    circulator.encrypted_secret_key.should_not == secret_key
    circulator.last_accessed_at.should == now

    circulator_user = CirculatorUser.find_by_circulator_and_user(circulator, @user)
    circulator_user.owner.should be_true

    post :create, circulator: {:serial_number => 'abc123', :notes => 'red one', :id => 'cc78787878787878'}
    response.should be_success
  end

  it 'should not create circulator if bad secret key' do
    bad_keys = ['1234', '6b714257175f73150228454466307d1z']
    bad_keys.each do |secret_key|
      serial_number = 'abc123'
      notes = 'red one'
      post(:create,
           circulator: {
             :serial_number => serial_number,
             :notes => notes,
           :id => '7878787878787878',
           :secret_key => secret_key
           }
          )
      response.code.should == '400'
      response.should_not be_success
    end
  end



  it 'should create circulator with no secret key' do
    post(:create,
         circulator: {
           :serial_number => 'abc123',
           :notes => 'red one',
           :id => '7878787878787878'
         }
    )
    response.should be_success
    returnedCirculator = JSON.parse(response.body)
    circ_id = returnedCirculator['circulatorId']
    circulator = Circulator.where(circulator_id: circ_id).first
    circulator.encrypted_secret_key.should == nil
  end

  it 'should return 400 if circulator address invalid' do
    post(:create,
         circulator: {
           :serial_number => 'abc123',
           :notes => 'red one',
           :id => '1234' # too short
         }
    )
    response.code.should == '400'
  end

  it 'should prevent duplicate circulators' do
    circulator_id = '8911898989898989'
    post :create, circulator: {:serial_number => 'abc123', :notes => 'red one', :id => circulator_id}
    response.should be_success
    post :create, circulator: {:serial_number => 'abc123', :notes => 'red one', :id => circulator_id}
    response.code.should == '409'
  end

  it 'should assign ownership correctly' do
    post :create, {circulator: {:serial_number => 'abc123', :notes => 'red one', :id => '8911898989898989'}, :owner => false}
    response.should be_success
    returnedCirculator = JSON.parse(response.body)

    circulator = Circulator.where(circulator_id: returnedCirculator['circulatorId']).first
    circulator_user = CirculatorUser.find_by_circulator_and_user(circulator, @user)
    circulator_user.owner.should_not be_true
  end

  it 'should provide a token' do
    Timecop.freeze(Time.zone.now.change(nsec: 0)) do
      post :token, :id => @circulator.circulator_id
      response.code.should == '200'
      result = JSON.parse(response.body)
      result['token'].should_not be_empty
      token = AuthToken.from_string result['token']
      token['iat'].should == Time.now.to_i
    end
  end

  it 'should return 400 when token is called without id' do
    post :token
    response.code.should == '400'
  end

  it 'should not provide a token if circulator does not exist' do
    post :token, :id => 'not-a-circulator'
    response.code.should == '403'
  end

  it 'should not provide a token if not a user' do
    post :token, :id => @other_circulator.circulator_id
    response.code.should == '403'
    result = JSON.parse(response.body)
    result['token'].should be_nil
  end

  it 'should delete the circulator' do
    post :destroy, :id => @circulator.circulator_id

    response.should be_success

    result = JSON.parse(response.body)

    Circulator.where(circulator_id: @circulator.circulator_id).first.should be_nil
    CirculatorUser.find_by_circulator_and_user(@circulator, @user).should be_nil
    @aa.reload.revoked?.should be_true
  end

  it 'should not delete a circulator that does not exist' do
    post :destroy, :id => "gibberish"
    response.should_not be_success
    response.code.should == '403'
    result = JSON.parse(response.body)
  end

  it 'should not delete the circulator if not the owner' do
    @circulator_user.owner = false
    @circulator_user.save!

    post :destroy, :id => @circulator.circulator_id
    response.code.should == '403'

    Circulator.find_by_id(@circulator.id).should_not be_nil
  end

  it 'should not delete the circulator if not a user' do
    post :destroy, :id => @other_circulator.id
    response.code.should == '403'

    Circulator.find_by_id(@other_circulator.id).should_not be_nil
  end

  it 'should not delete a circulator if admin' do
    token = ActorAddress.create_for_user(@admin_user, client_metadata: "create").current_token
    request.env['HTTP_AUTHORIZATION'] = token.to_jwt
    post :destroy, :id => @circulator.circulator_id
    response.code.should == '403'
    Circulator.find_by_id(@circulator.id).should_not be_nil
  end

  it 'should return 403 if admin deletes circulator that does not exist' do
    token = ActorAddress.create_for_user(@admin_user, client_metadata: "create").current_token
    request.env['HTTP_AUTHORIZATION'] = token.to_jwt
    post :destroy, :id => 'fake id'
    response.code.should == '403'
  end

  it 'should return 400 if destroy called without id' do
    post :destroy
    response.code.should == '400'
  end

  describe 'update' do
    it 'cannot update a circulator it does not own' do
      post(:update,
           {
             :id => @other_circulator.circulator_id,
           }
      )
      response.code.should == '403'
    end

    it 'should update last accessed at' do
      Timecop.freeze(Time.zone.now.change(nsec: 0)) do
        post(:update,
             {
               :id => @circulator.circulator_id,
             }
        )
        response.code.should == '200'
        @circulator.reload
        @circulator.last_accessed_at.should == Time.now.utc
      end
    end

    it 'should support updating the name' do
      post(:update,
            {
              :id => @circulator.circulator_id,
              circulator: {
                :name => 'new name'
              }
           }
      )
      response.code.should == '200'
      @circulator.reload
      @circulator.name.should == 'new name'
    end

    it 'should support updating the notes' do
      post(:update,
            {
              :id => @circulator.circulator_id,
              circulator: {
                :notes => 'new notes'
              }
           }
      )
      response.code.should == '200'
      @circulator.reload
      @circulator.notes.should == 'new notes'
    end
  end
  context 'notify_clients' do
    before :each do
      issued_at = (Time.now.to_f * 1000).to_i

      service_claim = {
        iat: issued_at,
        service: 'Messaging'
      }
      @key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
      @service_token = JSON::JWT.new(service_claim.as_json).sign(@key.to_s).to_s
      request.env['HTTP_AUTHORIZATION'] = @service_token

      stub_sns_publish()
      Api::V0::CirculatorsController.any_instance.stub(:delete_endpoint) do |arn|
        @deleted_endpoints << arn
      end
      @published_messages = []
      @deleted_endpoints = []

      p = PushNotificationToken.new
      p.actor_address = @user_aa
      p.endpoint_arn = "arn:aws:sns:us-east-1:0217963864089:endpoint/APNS_SANDBOX/joule-ios-dev/f56b2215-2121-3b21-b172-5d519ab0d123"
      p.app_name ='joule'
      p.device_token = 'not-a-device-token'
      p.save!
    end

    describe 'notify_clients' do
      context 'disconnect while cooking' do
        it 'sends a notification' do
          BetaFeatureService.stub(:user_has_feature).with(anything(), 'disconnect_while_cooking_notification').and_return(true)
          post(
            :notify_clients,
            id: @circulator.circulator_id,
            notification_type: 'disconnect_while_cooking'
          )
          expect(response.code).to eq '200'
          expect(@published_messages.length).to eq 1
          msg = JSON.parse(@published_messages[0][:msg])
          apns = JSON.parse msg['APNS']
          gcm = JSON.parse msg['GCM']
          expect(apns['aps']['content-available']).to eq 0
          expect(gcm['data']['content_available']).to eq false
        end
      end

      context 'button pressed' do
        it 'sends a notification' do
          post(
            :notify_clients,
            id: @circulator.circulator_id,
            notification_type: 'circulator_error_button_pressed'
          )
          expect(response.code).to eq '200'
          expect(@published_messages.length).to eq 1
          msg = JSON.parse(@published_messages[0][:msg])
          apns = JSON.parse msg['APNS']
          gcm = JSON.parse msg['GCM']
          expect(apns['aps']['content-available']).to eq 1
          expect(gcm['data']['content_available']).to eq true
        end
      end



      let(:notification_type) { 'water_heated' }

      context 'no idempotency key is specified' do
        it 'should notify clients' do
          post(
            :notify_clients,
            id: @circulator.circulator_id,
            notification_type: notification_type
          )
          expect(@published_messages.length).to eq 1
          msg = JSON.parse(@published_messages[0][:msg])
          apns = JSON.parse msg['APNS']
          expect(apns['aps']['content-available']).to eq 0
        end

        it 'should notify clients with Joule name if provided' do
          notification_types = [
            'guided_water_heated',
            'water_heated',
            'circulator_error_hardware_failure',
            'circulator_error_button_pressed',
            'circulator_error_low_water_level',
            'circulator_error_tipped_over',
            'circulator_error_overheating',
            'circulator_error_power_loss',
            'circulator_error_unknown_reason',
            'disconnect_while_cooking',
          ]

          for type in notification_types
            post(
              :notify_clients,
              id: @circulator.circulator_id,
              notification_type: type,
              notification_params: {
                joule_name: 'BurgerBob'
              }
            )
            msg = JSON.parse(@published_messages[-1][:msg])
            apns = JSON.parse msg['APNS']
            expect(apns['aps']['alert']).to include('BurgerBob')
          end

        end

        it 'should delete token if endpoint disabled' do
          Api::V0::CirculatorsController.any_instance.stub(:publish_json_message) do |arn, msg|
            raise Aws::SNS::Errors::EndpointDisabled.new('foo', 'bar')
          end
          token = PushNotificationToken.where(:actor_address_id => @user_aa.id, :app_name => 'joule').first
          expect(token).to_not be_nil
          arn = token.endpoint_arn
          post(
            :notify_clients,
            id: @circulator.circulator_id,
            notification_type: notification_type
          )

          # Expect token to be deleted
          token = PushNotificationToken.where(:actor_address_id => @user_aa.id, :app_name => 'joule').first
          expect(token).to be_nil
          expect(@deleted_endpoints).to eq([arn])
        end
      end

      context 'idempotency key is specified' do
        let(:idempotency_key) { '123' }
        let(:cache_key) { "notifications.#{@circulator.id}.#{idempotency_key}" }
        after :each do
          Rails.cache.delete(cache_key)
        end

        context 'notification cache contains key' do
          before { Rails.cache.write(cache_key, true) }

          it 'does not send notification' do
            post(
              :notify_clients,
              id: @circulator.circulator_id,
              notification_type: notification_type,
              idempotency_key: idempotency_key
            )
            expect(response.code).to eq '200'
            expect(@published_messages.length).to eq 0
          end
        end

        context 'notification cache does not contain key' do
          it 'sends notification' do
            post(
              :notify_clients,
              id: @circulator.circulator_id,
              notification_type: notification_type,
              idempotency_key: idempotency_key
            )
            expect(response.code).to eq '200'
            expect(@published_messages.length).to eq 1
          end
        end

        context 'notification was sent more than 72 hours ago' do
          it 'sends a new notification' do
            # We should see two notifications in total
            post(
              :notify_clients,
              id: @circulator.circulator_id,
              notification_type: notification_type,
              idempotency_key: idempotency_key
            )
            expect(response.code).to eq '200'
            Timecop.freeze(73.hours)
            post(
              :notify_clients,
              id: @circulator.circulator_id,
              notification_type: notification_type,
              idempotency_key: idempotency_key
            )
            expect(response.code).to eq '200'
            expect(@published_messages.length).to eq 2
          end
        end

        context 'notification was sent less than 72 hours ago' do
          it 'does not send a new notification' do
            post(
              :notify_clients,
              id: @circulator.circulator_id,
              notification_type: notification_type,
              idempotency_key: idempotency_key
            )
            expect(response.code).to eq '200'
            Timecop.freeze(71.hours)
            post(
              :notify_clients,
              id: @circulator.circulator_id,
              notification_type: notification_type,
              idempotency_key: idempotency_key
            )
            expect(response.code).to eq '200'
            expect(@published_messages.length).to eq 1
          end
        end
      end

      it 'should reject unknown notification types' do
        post(:notify_clients, {
          :id => @circulator.circulator_id,
          :notification_type => 'gibberish'})
        response.code.should == '400'
      end

      it 'should return 404 when circulator not found' do
        post(:notify_clients, {
          :id => 1232132123,
          :notification_type => 'gibberish'})
        response.code.should == '404'
      end

      it 'should not notify revoked addresses'do
        # not stubbed reply for publish since it shouldn't be called
        @user_aa.revoke
        post(:notify_clients, {
          :id => @circulator.circulator_id,
          :notification_type => 'water_heated'})
        response.code.should == '200'
      end
    end
  end

  context 'coefficients' do
    it 'should return coefficients' do
      identifyObject = {
        hardwareVersion: "JL.p4",
        appFirmwareVersion: "48"
      }
      post :coefficients, identify: identifyObject
      response.should be_success
      coefficientsResponse = JSON.parse(response.body)
      coefficientsResponse['hardwareVersion'].should eq('JL.p4')
      coefficientsResponse['appFirmwareVersion'].should eq('48')
      coefficientsResponse['coefficients'].keys.should eq(['tempAdcBias','tempAdcScale','tempRef','tempCoeffA','tempCoeffB','tempCoeffC'])
    end

    it 'should return empty object' do
      identifyObject = {
        hardwareVersion: "2.1",
        appFirmwareVersion: "2.1"
      }
      post :coefficients, identify: identifyObject
      response.should be_success
      coefficientsResponse = JSON.parse(response.body)
      coefficientsResponse['hardwareVersion'].should eq('2.1')
      coefficientsResponse['appFirmwareVersion'].should eq('2.1')
      coefficientsResponse['coefficients'].should eq({})
    end

    it 'should return 404 error when identifyObject not provided' do
      post :coefficients
      response.should_not be_success
      response.code.should eq('404')
    end

    it 'should return error' do
      identifyObject = {}
      post :coefficients, identify: identifyObject
      response.should_not be_success
      response.code.should eq('404')
    end
  end

  private

  def stub_sns_publish
    Api::V0::CirculatorsController.any_instance.stub(:publish_json_message) do |arn, msg|
      @published_messages << {arn: arn, msg: msg}
    end
  end
end
