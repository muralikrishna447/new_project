require 'spec_helper'

describe Api::V0::PushNotificationTokensController do
  include Docs::V0::PushNotificationTokens::Api

  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    @aa = ActorAddress.create_for_user(@user, client_metadata: "create")
    token = @aa.current_token
    request.env['HTTP_AUTHORIZATION'] = token.to_jwt

  end
  describe 'DELETE #destroy' do
    include Docs::V0::PushNotificationTokens::Destroy
    context "/destroy", :dox do
      before :each do
        mock_sns_deregister
        @token = Fabricate :push_notification_token, actor_address_id: @aa.id, app_name: 'joule',\
          endpoint_arn: 'arn://1234567890', device_token:'abc'
      end

      it 'deletes a token using token while signed in' do
        delete :destroy, params: {device_token: @token.device_token}
        PushNotificationToken.all.length.should == 0
      end

      it 'deletes a token using address while signed in' do
        delete :destroy, params: {device_token: "different-token"}
        PushNotificationToken.all.length.should == 0
      end

      it 'deletes "both" tokens when signed in' do
        second_aa = ActorAddress.create_for_user(@user, client_metadata: "create")
        @token = Fabricate :push_notification_token, actor_address_id: second_aa.id, app_name: 'joule',\
          endpoint_arn: 'arn://12345678902', device_token:'second_token'

        delete :destroy, params: {device_token: "second_token"}
        PushNotificationToken.all.length.should == 0
      end

      it 'deletes a token using token while not signed in' do
        request.env['HTTP_AUTHORIZATION'] = nil
        delete :destroy, params: {device_token: @token.device_token}
        PushNotificationToken.all.length.should == 0
      end

      it 'does not delete random things' do
        request.env['HTTP_AUTHORIZATION'] = nil
        delete :destroy, params: {device_token: "different-token"}
        PushNotificationToken.all.length.should == 1
      end
    end
  end

  describe 'POST #create' do
    include Docs::V0::PushNotificationTokens::Create
    context "/create", :dox do
      before :each do
        mock_sns_enable
        mock_sns_register
      end

      it 'Registers a token' do
        post :create, params: {:app_name => 'joule',
          :platform => 'ios',
          :device_token => 'mehmehmehmeh'}
        response.should be_success
      end

      it 'Registers a token for beta app' do
        post :create, params: {:app_name => 'joule-beta',
          :platform => 'ios',
          :device_token => 'mehmehmehmeh'}
        response.should be_success
      end

      it 'Handles duplicate registraction' do
        post :create, params: {:app_name => 'joule',
          :platform => 'ios',
          :device_token => 'mehmehmehmeh'}
        response.should be_success

        post :create, params: {:app_name => 'joule',
          :platform => 'ios',
          :device_token => 'mehmehmehmeh'}
        response.should be_success
      end

      it 'Overwrites old address when token is reused' do
        mock_sns_deregister
        post :create, params: {:app_name => 'joule',
          :platform => 'ios',
          :device_token => 'mehmehmehmeh'}
        response.should be_success
        PushNotificationToken.all.first.actor_address_id.should == @aa.id

        @second_user = Fabricate :user, email: 'johndoe2@chefsteps.com', password: '123456', name: 'John Doe'
        aa = ActorAddress.create_for_user(@user, client_metadata: "create")
        token = aa.current_token
        request.env['HTTP_AUTHORIZATION'] = token.to_jwt

        post :create, params: {app_name: 'joule', platform: 'ios', device_token: 'mehmehmehmeh'}
        response.should be_success
        PushNotificationToken.all.first.actor_address_id.should == aa.id
      end

      it 'Handles AWS exceptions' do
        Api::V0::PushNotificationTokensController.any_instance.stub(:create_platform_endpoint)
          .and_raise Aws::SNS::Errors::InvalidParameter.new("message", "requestId")
          post :create, params: {:app_name => 'joule',
            :platform => 'ios',
            :device_token => 'mehmehmehmeh'}
          response.code.should == "400"
      end

      it 'Returns unhelpful error when other params are bad' do
        mock_sns_register
        post :create, params: {:app_name => 'j',
          :platform => 'i',
          :device_token => 'm'}
        response.code.should == "400"

        mock_sns_register
        post :create, params: {:app_name => 'j',
          :platform => 'ios',
          :device_token => 'm'}
        response.code.should == "400"

      end

      def mock_sns_register
        Api::V0::PushNotificationTokensController.any_instance.stub(:create_platform_endpoint)
          .and_return(OpenStruct.new(endpoint_arn: 'some_arn_that_is_ten_chars'))
      end
    end
  end

  def mock_sns_deregister
    Api::V0::PushNotificationTokensController.any_instance.stub(:delete_platform_endpoint)
      .and_return(OpenStruct.new())
  end

  def mock_sns_enable
    Api::V0::PushNotificationTokensController.any_instance.stub(:ensure_platform_endpoint_is_enabled)
      .and_return(OpenStruct.new())
  end
end
