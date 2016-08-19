describe Api::V0::CirculatorsController do
  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
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
      response.should_not be_success
    end
  end

  it 'should create circulator with no secret key' do
    @circulator
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
      
      p = PushNotificationToken.new
      p.actor_address = @user_aa
      p.endpoint_arn = "arn:aws:sns:us-east-1:0217963864089:endpoint/APNS_SANDBOX/joule-ios-dev/f56b2215-2121-3b21-b172-5d519ab0d123"
      p.app_name ='joule'
      p.device_token = 'not-a-device-token'
      p.save!
    end

    describe 'notify_clients' do
      let(:notification_type) { 'water_heated' }

      context 'no idempotency key is specified' do
        it 'should notify clients' do
          expect_publish_notification(true)
          post(
            :notify_clients,
            id: @circulator.circulator_id,
            notification_type: notification_type
          )
          expect(response.code).to eq '200'
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
            expect_publish_notification(false)
            post(
              :notify_clients,
              id: @circulator.circulator_id,
              notification_type: notification_type,
              idempotency_key: idempotency_key
            )
            expect(response.code).to eq '200'
          end
        end

        context 'notification cache does not contain key' do
          it 'sends notification' do
            expect_publish_notification(true)
            post(
              :notify_clients,
              id: @circulator.circulator_id,
              notification_type: notification_type,
              idempotency_key: idempotency_key
            )
            expect(response.code).to eq '200'
          end
        end

        context 'notification was sent more than 72 hours ago' do
          it 'sends a new notification' do
            # We should see two notifications in total
            expect_publish_notification(true, 2)
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
          end
        end

        context 'notification was sent less than 72 hours ago' do
          it 'does not send a new notification' do
            # We should only see one notification
            expect_publish_notification(true, 1)
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

  private

  def expect_publish_notification(should_receive, times = 1)
    if should_receive
      Api::V0::CirculatorsController.any_instance.should_receive(:publish_notification).exactly(times).times
    else
      Api::V0::CirculatorsController.any_instance.should_not_receive(:publish_notification)
    end
  end
end
