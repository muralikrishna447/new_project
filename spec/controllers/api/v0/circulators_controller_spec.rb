describe Api::V0::CirculatorsController do
  include Docs::V0::Circulators::Api

  before :each do
    @user = Fabricate :user, id: 12345, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
    @circulator = Fabricate :circulator, notes: 'some notes', circulator_id: '1212121212121212', name: 'my name', hardware_version: 'J5', hardware_options: 0, build_date: 1729, pcba_revision: "131", model_number: "300"
    @admin_user = Fabricate :user, email: 'admin@chefsteps.com', password: '123456', name: 'John Doe', role: 'admin'

    @aa = ActorAddress.create_for_circulator @circulator
    @other_circulator = Fabricate :circulator, notes: 'some other notes', circulator_id: '4545454545454545'
    @circulator_user = Fabricate :circulator_user, user: @user, circulator: @circulator, owner: true

    @user_aa = ActorAddress.create_for_user(@user, client_metadata: "create")
    @second_user_aa = ActorAddress.create_for_user(@user, client_metadata: "create")
    token = @user_aa.current_token
    request.env['HTTP_AUTHORIZATION'] = token.to_jwt
  end

  after :each do
    Timecop.return
  end

  context 'GET /circulators', :dox do
    describe 'GET #index' do
      include Docs::V0::Circulators::Index
      it 'should list circulators' do
        get :index

        response.should be_success
        circulators = JSON.parse(response.body)
        circulators.length.should == 1
        circulators[0]['circulatorId'].should == @circulator.circulator_id
        circulators[0]['notes'].should == 'some notes'
        circulators[0]['secretKey'].should == nil
        circulators[0]['name'].should == 'my name'
        circulators[0]['hardwareVersion'].should == 'J5'
        circulators[0]['hardwareOptions'].should == 0
        circulators[0]['buildDate'].should == 1729
        circulators[0]['pcbaRevision'].should == "131"
        circulators[0]['modelNumber'].should == "300"
      end
    end
  end

  context 'POST /circulators', :dox do
    describe 'POST #create' do
      include Docs::V0::Circulators::Create
      it 'should create circulator' do
        secret_key = '6b714257175f73150228454466307d16'
        serial_number = 'abc123'
        notes = 'red one'
        name = 'my name is my name'
        hardware_version = 'J5'
        hardware_options = 0
        build_date = 1729
        pcba_revision = "131"
        model_number = "300"

        now = nil
        # https://github.com/travisjeffery/timecop/issues/176
        Timecop.freeze(Time.zone.now.change(nsec: 0)) do
          post(:create,
              params: {circulator: {
                  :serial_number => serial_number,
                  :notes => notes,
                  :name => name,
                  :id => '7878787878787878',
                  :secret_key => secret_key,
                  :hardwareVersion => hardware_version,
                  :hardwareOptions => hardware_options,
                  :buildDate => build_date,
                  :pcbaRevision => pcba_revision,
                  :modelNumber => model_number
              }}
          )
          now = Time.now
        end
        response.should be_success
        returnedCirculator = JSON.parse(response.body)

        returnedCirculator['secretKey'].should == secret_key
        returnedCirculator['serialNumber'].should == serial_number
        returnedCirculator['notes'].should == notes
        returnedCirculator['name'].should == name
        returnedCirculator['hardwareVersion'].should == hardware_version
        returnedCirculator['hardwareOptions'].should == hardware_options
        returnedCirculator['buildDate'].should == build_date
        returnedCirculator['pcbaRevision'].should == pcba_revision
        returnedCirculator['modelNumber'].should == model_number
        returnedCirculator['lastAccessedAt'].to_time.utc.iso8601.should == now.utc.iso8601
        circulator = Circulator.where(circulator_id: returnedCirculator['circulatorId']).first
        circulator.should_not be_nil
        circulator.notes.should == notes
        circulator.name.should == name
        circulator.users.first.should == @user
        circulator.encrypted_secret_key.should_not == secret_key
        circulator.last_accessed_at.should == now

        circulator_user = CirculatorUser.find_by_circulator_and_user(circulator, @user)
        circulator_user.owner.should be true

        post :create, params: {circulator: {:serial_number => 'abc123', :notes => 'red one', :id => 'cc78787878787878'}}
        response.should be_success
      end

      it 'should not create circulator if bad secret key' do
        bad_keys = ['1234', '6b714257175f73150228454466307d1z']
        bad_keys.each do |secret_key|
          serial_number = 'abc123'
          notes = 'red one'
          post(:create,
              params: {circulator: {
                  :serial_number => serial_number,
                  :notes => notes,
                  :id => '7878787878787878',
                  :secret_key => secret_key
              }}
          )
          response.code.should == '400'
          response.should_not be_success
        end
      end

      it 'should create circulator with no secret key' do
        post(:create,
            params: {circulator: {
                :serial_number => 'abc123',
                :notes => 'red one',
                :id => '7878787878787878'
            }}
        )
        response.should be_success
        returnedCirculator = JSON.parse(response.body)
        circ_id = returnedCirculator['circulatorId']
        circulator = Circulator.where(circulator_id: circ_id).first
        circulator.encrypted_secret_key.should == nil
      end

      it 'should return 400 if circulator address invalid' do
        post(:create,
            params: {circulator: {
                :serial_number => 'abc123',
                :notes => 'red one',
                :id => '1234' # too short
            }}
        )
        response.code.should == '400'
      end

      it 'should prevent duplicate circulators' do
        circulator_id = '8911898989898989'
        post :create, params: {circulator: {:serial_number => 'abc123', :notes => 'red one', :id => circulator_id}}
        response.should be_success
        post :create, params: {circulator: {:serial_number => 'abc123', :notes => 'red one', :id => circulator_id}}
        response.code.should == '409'
      end

      it 'should assign ownership correctly' do
        post :create, params: {circulator: {:serial_number => 'abc123', :notes => 'red one', :id => '8911898989898989'}, :owner => false}, as: :json
        response.should be_success
        returnedCirculator = JSON.parse(response.body)

        circulator = Circulator.where(circulator_id: returnedCirculator['circulatorId']).first
        circulator_user = CirculatorUser.find_by_circulator_and_user(circulator, @user)
        circulator_user.owner.should_not be true
      end
    end
  end

  context 'POST /token', :dox do
    describe 'POST #token' do
      include Docs::V0::Circulators::Token
      it 'should provide a token' do
        Timecop.freeze(Time.zone.now.change(nsec: 0)) do
          post :token, params: {:id => @circulator.circulator_id}
          response.code.should == '200'
          result = JSON.parse(response.body)
          result['token'].should_not be_empty
          token = AuthToken.from_string result['token']

          # See:
          # https://github.com/travisjeffery/timecop/issues/146
          (token['iat'] - Time.now.to_i).abs.should <= 2
        end
      end

      it 'should return 400 when token is called without id' do
        post :token
        response.code.should == '400'
      end

      it 'should not provide a token if circulator does not exist' do
        post :token, params: {:id => 'not-a-circulator'}
        response.code.should == '403'
      end

      it 'should not provide a token if not a user' do
        post :token, params: {:id => @other_circulator.circulator_id}
        response.code.should == '403'
        result = JSON.parse(response.body)
        result['token'].should be_nil
      end
    end
  end

  context 'DELETE /destroy', :dox do
    describe 'POST #destroy' do
      include Docs::V0::Circulators::Destroy
      it 'should delete the circulator' do
        post :destroy, params: {:id => @circulator.circulator_id}

        response.should be_success

        result = JSON.parse(response.body)

        Circulator.where(circulator_id: @circulator.circulator_id).first.should be_nil
        CirculatorUser.find_by_circulator_and_user(@circulator, @user).should be_nil
        @aa.reload.revoked?.should be true
      end

      it 'should not delete a circulator that does not exist' do
        post :destroy, params: {:id => "gibberish"}
        response.should_not be_success
        response.code.should == '403'
        result = JSON.parse(response.body)
      end

      it 'should not delete the circulator if not the owner' do
        @circulator_user.owner = false
        @circulator_user.save!

        post :destroy, params: {:id => @circulator.circulator_id}
        response.code.should == '403'

        Circulator.find_by_id(@circulator.id).should_not be_nil
      end

      it 'should not delete the circulator if not a user' do
        post :destroy, params: {:id => @other_circulator.id}
        response.code.should == '403'

        Circulator.find_by_id(@other_circulator.id).should_not be_nil
      end

      it 'should not delete a circulator if admin' do
        token = ActorAddress.create_for_user(@admin_user, client_metadata: "create").current_token
        request.env['HTTP_AUTHORIZATION'] = token.to_jwt
        post :destroy, params: {:id => @circulator.circulator_id}
        response.code.should == '403'
        Circulator.find_by_id(@circulator.id).should_not be_nil
      end

      it 'should return 403 if admin deletes circulator that does not exist' do
        token = ActorAddress.create_for_user(@admin_user, client_metadata: "create").current_token
        request.env['HTTP_AUTHORIZATION'] = token.to_jwt
        post :destroy, params: {:id => 'fake id'}
        response.code.should == '403'
      end

      it 'should return 400 if destroy called without id' do
        post :destroy
        response.code.should == '400'
      end
    end
  end

  context 'PUT /update', :dox do
    describe 'update' do
      include Docs::V0::Circulators::Update
      it 'cannot update a circulator it does not own' do
        post(:update,
            params: {
                :id => @other_circulator.circulator_id,
            }
        )
        response.code.should == '403'
      end

      it 'should update last accessed at' do
        Timecop.freeze(Time.zone.now.change(nsec: 0)) do
          post(:update,
              params: {
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
            params: {
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
            params: {
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
  end

  context 'emoji handling', :dox do
    describe 'GET #index' do
      include Docs::V0::Circulators::Index
      before :each do
        @emoji_user = Fabricate :user, id: 77898, email: 'emoji@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
        @emoji_name = "Burger\u{1f354}".encode('utf-8')
        @emoji_notes = "I love \u{1f354}s".encode('utf-8')
        @emoji_circulator = Fabricate :circulator, notes: @emoji_notes,
                                      circulator_id: '4545454545454577', name: @emoji_name

        @circulator_user = Fabricate :circulator_user, user: @emoji_user, circulator: @emoji_circulator, owner: true
        @emoji_user_aa = ActorAddress.create_for_user(@emoji_user, client_metadata: "create")
        token = @emoji_user_aa.current_token
        request.env['HTTP_AUTHORIZATION'] = token.to_jwt
      end

      it 'should list circulators' do
        get :index

        response.should be_success
        circulators = JSON.parse(response.body)
        circulators[0]['name'].should == @emoji_name
        circulators[0]['notes'].should == @emoji_notes
      end
    end
  end

  context 'notify_clients', :dox do
    describe 'POST #notify_clients' do
      include Docs::V0::Circulators::NotifyClients
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
        stub_dynamo_save()
        allow_any_instance_of(Api::V0::CirculatorsController).to receive(:delete_endpoint) do |value, arn|
          @deleted_endpoints << arn
        end
        @published_messages = []
        @saved_notifications = []
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
            allow_any_instance_of(BetaFeature).to receive(:user_has_feature).with(anything(), 'disconnect_while_cooking_notification').and_return(true)

            post(
                :notify_clients,
                params: {id: @circulator.circulator_id,
                        notification_type: 'disconnect_while_cooking'}
            )
            expect(response.code).to eq '200'
            expect(@published_messages.length).to eq 1
            expect(@saved_notifications.length).to eq 1
            expect(@saved_notifications[0]["notification_type"]).to eq 'disconnect_while_cooking'
            expect(@saved_notifications[0]["message_id"]).to_not be_nil
            msg = JSON.parse(@published_messages[0][:msg])
            apns = JSON.parse msg['APNS']
            gcm = JSON.parse msg['GCM']
            expect(apns['circulator_address']).to eq @circulator.circulator_id
            expect(gcm['data']['circulator_address']).to eq @circulator.circulator_id
            expect(gcm['data']['title']).to eq 'Joule'
          end
        end

        context 'button pressed' do
          it 'sends a notification' do
            post(
                :notify_clients,
                params: {id: @circulator.circulator_id,
                        notification_type: 'circulator_error_button_pressed'}
            )
            expect(response.code).to eq '200'
            expect(@published_messages.length).to eq 1
            msg = JSON.parse(@published_messages[0][:msg])
            apns = JSON.parse msg['APNS']
            gcm = JSON.parse msg['GCM']
          end
        end

        context 'background notifications' do
          it 'sends timer_updated as a background notification' do
            post(
                :notify_clients,
                params: {format: 'json',
                        id: @circulator.circulator_id,
                        notification_type: 'timer_updated',
                        notification_params: {
                            finish_timestamp: 1234,
                            feed_id: 0001,
                            guide_id: 'guide-id',
                            timer_id: 'timer-id',
                            joule_name: 'joule-name',
                        }}
            )
            expect(@published_messages.length).to eq 1
            msg = JSON.parse(@published_messages[0][:msg])
            apns = JSON.parse msg['APNS']
            gcm = JSON.parse msg['GCM']

            expect(gcm['data']['content-available']).to eq '1'
            expect(gcm['data']['feed_id']).to eq '1'
            expect(gcm['data']['finish_timestamp']).to eq '1234'
            expect(gcm['data']['guide_id']).to eq 'guide-id'
            expect(gcm['data']['timer_id']).to eq 'timer-id'
            expect(gcm['data']['joule_name']).to eq 'joule-name'
            
            expect(apns['aps']['content-available']).to eq 1
            expect(apns['notId']).to_not be_nil
            expect(apns['notId']).to eq gcm['data']['notId']
            expect(apns['finish_timestamp']).to eq '1234'
            expect(apns['feed_id']).to eq '1'
            expect(apns['guide_id']).to eq 'guide-id'
            expect(apns['timer_id']).to eq 'timer-id'
            expect(apns['joule_name']).to eq 'joule-name'
          end
          
          it 'sends still_preheating as a background notification' do
            post(
                :notify_clients,
                params: {format: 'json',
                        id: @circulator.circulator_id,
                        notification_type: 'still_preheating',
                        notification_params: {
                            cook_time: 60,
                            feed_id: 0001,
                            joule_name: 'joule-name',
                        }}
            )
            expect(@published_messages.length).to eq 1
            msg = JSON.parse(@published_messages[0][:msg])
            apns = JSON.parse msg['APNS']
            gcm = JSON.parse msg['GCM']

            expect(gcm['data']['content-available']).to eq '1'
            expect(gcm['data']['cook_time']).to eq '60'
            expect(gcm['data']['feed_id']).to eq '1'
            expect(gcm['data']['joule_name']).to eq 'joule-name'
            
            expect(apns['aps']['content-available']).to eq 1
            expect(apns['notId']).to_not be_nil
            expect(apns['notId']).to eq gcm['data']['notId']
            expect(apns['cook_time']).to eq '60'
            expect(apns['feed_id']).to eq '1'
            expect(apns['joule_name']).to eq 'joule-name'
          end
        end

        let(:notification_type) { 'water_heated' }

        context 'no idempotency key is specified' do
          it 'should notify clients' do
            post(
                :notify_clients,
                params: {id: @circulator.circulator_id,
                        notification_type: notification_type}
            )
            expect(@published_messages.length).to eq 1
            msg = JSON.parse(@published_messages[0][:msg])
            apns = JSON.parse msg['APNS']
          end

          it 'should notify both joule-beta and joule apps' do
            p = PushNotificationToken.new
            p.actor_address = @second_user_aa
            p.endpoint_arn = "beta-endpoint-arn"
            p.app_name ='joule-beta'
            p.device_token = 'beta-device-token'
            p.save!

            post(
                :notify_clients,
                params: {id: @circulator.circulator_id,
                        notification_type: notification_type}
            )
            arns = @published_messages.map {|m| m[:arn]}
            expect(arns.length).to eq 2
            expect(arns).to include('beta-endpoint-arn')
          end

          it 'should notify clients with emoji Joule name' do
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

            name = "BurgerBob\u{1f354}".encode('utf-8')

            for type in notification_types
              post(
                  :notify_clients,
                  params: {id: @circulator.circulator_id,
                          notification_type: type,
                          notification_params: {
                              joule_name: name
                          }}
              )
              msg = JSON.parse(@published_messages[-1][:msg])
              apns = JSON.parse msg['APNS']
              gcm = JSON.parse msg['GCM']
              expect(apns['aps']['alert']).to include(name)
              expect(gcm['data']['message']).to include(name)
            end

          end

          it 'should fallback to default message for nil template vars' do
            post(
                :notify_clients,
                params: {id: @circulator.circulator_id,
                        notification_type: 'water_heated',
                        notification_params: {
                            joule_name: nil
                        }}
            )
            msg = JSON.parse(@published_messages[-1][:msg])
            apns = JSON.parse msg['APNS']
            expect(apns['aps']['alert']).to include('Your water has heated!')
          end

          it 'should pass circulator_address in params' do
            post(
                :notify_clients,
                params: {format: 'json',
                        id: @circulator.circulator_id,
                        notification_type: 'water_heated',
                        notification_params: {
                            joule_name: nil,
                            feed_id: 123,
                        }}
            )
            msg = JSON.parse(@published_messages[-1][:msg])
            apns = JSON.parse msg['APNS']
            gcm = JSON.parse msg['GCM']
            expect(apns['circulator_address']).to eq @circulator.circulator_id
            expect(gcm['data']['circulator_address']).to eq @circulator.circulator_id
            expect(apns['feed_id']).to eq '123'
            expect(gcm['data']['feed_id']).to eq '123'
          end

          it 'should pass cook_start_timestamp in params' do
            post(
                :notify_clients,
                params: {format: 'json',
                        id: @circulator.circulator_id,
                        notification_type: 'timer_updated',
                        notification_params: {
                            cook_start_timestamp: 123,
                        }}
            )
            msg = JSON.parse(@published_messages[-1][:msg])
            apns = JSON.parse msg['APNS']
            gcm = JSON.parse msg['GCM']
            expect(apns['cook_start_timestamp']).to eq '123'
            expect(gcm['data']['cook_start_timestamp']).to eq '123'
          end

          it 'should not be able to overwrite reserved fields' do
            post(
              :notify_clients,
              params: {format: 'json',
                      id: @circulator.circulator_id,
                      notification_type: 'water_heated',
                      notification_params: {
                          joule_name: nil,
                          message: 'BAD',
                          alert: 'BAD',
                          sound: 'BAD',
                          title: 'BAD',
                          feed_id: 123,
                      }}
            )
            msg = JSON.parse(@published_messages[-1][:msg])
            apns = JSON.parse msg['APNS']
            gcm = JSON.parse msg['GCM']
            for k in ['message', 'alert', 'sound', 'title']
              apns['aps'][k].should_not == 'BAD'
              gcm['data'][k].should_not == 'BAD'
            end
          end

          it 'should delete token if endpoint disabled' do
            allow_any_instance_of(Api::V0::CirculatorsController).to receive(:publish_json_message) do |value, arn, msg|
              raise Aws::SNS::Errors::EndpointDisabled.new('foo', 'bar')
            end
            token = PushNotificationToken.where(:actor_address_id => @user_aa.id, :app_name => 'joule').first
            expect(token).to_not be_nil
            arn = token.endpoint_arn
            post(
                :notify_clients,
                params: {format: 'json',
                        id: @circulator.circulator_id,
                        notification_type: notification_type}
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
                  params: {format: 'json',
                          id: @circulator.circulator_id,
                          notification_type: notification_type,
                          idempotency_key: idempotency_key}
              )
              expect(response.code).to eq '200'
              expect(@published_messages.length).to eq 0
            end
          end

          context 'notification cache does not contain key' do
            it 'sends notification' do
              post(
                  :notify_clients,
                  params: {format: 'json',
                          id: @circulator.circulator_id,
                          notification_type: notification_type,
                          idempotency_key: idempotency_key}
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
                  params: {format: 'json',
                          id: @circulator.circulator_id,
                          notification_type: notification_type,
                          idempotency_key: idempotency_key}
              )
              expect(response.code).to eq '200'
              Timecop.freeze(73.hours)
              post(
                  :notify_clients,
                  params: {format: 'json',
                          id: @circulator.circulator_id,
                          notification_type: notification_type,
                          idempotency_key: idempotency_key}
              )
              expect(response.code).to eq '200'
              expect(@published_messages.length).to eq 2
            end
          end

          context 'notification was sent less than 72 hours ago' do
            it 'does not send a new notification' do
              post(
                  :notify_clients,
                  params: {format: 'json',
                          id: @circulator.circulator_id,
                          notification_type: notification_type,
                          idempotency_key: idempotency_key}
              )
              expect(response.code).to eq '200'
              Timecop.freeze(71.hours)
              post(
                  :notify_clients,
                  params: {format: 'json',
                          id: @circulator.circulator_id,
                          notification_type: notification_type,
                          idempotency_key: idempotency_key}
              )
              expect(response.code).to eq '200'
              expect(@published_messages.length).to eq 1
            end
          end
        end

        it 'should reject unknown notification types' do
          post(:notify_clients, params: {
            :id => @circulator.circulator_id,
            :notification_type => 'gibberish'})
          response.code.should == '400'
        end

        it 'should return 404 when circulator not found' do
          post(:notify_clients, params: {
            :id => 1232132123,
            :notification_type => 'gibberish'})
          response.code.should == '404'
        end

        it 'should not notify revoked addresses'do
          # not stubbed reply for publish since it shouldn't be called
          @user_aa.revoke
          post(:notify_clients, params: {
            :id => @circulator.circulator_id,
            :notification_type => 'water_heated'})
          response.code.should == '200'
        end
      end
    end
  end

  context 'coefficients', :dox do
    describe 'POST #coefficients' do
      include Docs::V0::Circulators::Coefficients
      it 'should return coefficients' do
        identifyObject = {
          hardwareVersion: "JL.p4",
          appFirmwareVersion: "48"
        }
        post :coefficients, params: {identify: identifyObject}
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
        post :coefficients, params: {identify: identifyObject}
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
        post :coefficients, params: {identify: identifyObject}
        response.should_not be_success
        response.code.should eq('404')
      end
    end
  end

  private

  def stub_sns_publish
    allow_any_instance_of(Api::V0::CirculatorsController).to receive(:publish_json_message) do |value, arn, msg|
      @published_messages << {arn: arn, msg: msg}
      {:message_id => SecureRandom.uuid}
    end
  end

  def stub_dynamo_save
    allow_any_instance_of(Api::V0::CirculatorsController).to receive(:save_push_notification_item_to_dynamo) do |value, item|
      @saved_notifications << item
    end
  end
end
