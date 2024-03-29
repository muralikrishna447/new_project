describe Api::V0::PasswordsController do
  include Docs::V0::Passwords::Api

  before :each do
    Api::BaseController.send(:public, *Api::BaseController.protected_instance_methods)
    @base_controller = Api::BaseController.new
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    @aa = ActorAddress.create_for_user @user, client_metadata: "web"
  end

  describe 'PUT #update' do
    include Docs::V0::Passwords::Update
    context 'PUT /update', :dox do
      before :each do
        request.env['HTTP_AUTHORIZATION'] = @aa.current_token.to_jwt
      end

      it 'should not update a user password if current password is not correct' do
        put :update, params: {id: @user.id, current_password: 'SomeWrongPassword', new_password: 'SomeNewPassword'}
        response.should_not be_success
      end

      it 'should update a users password' do
        old_encrypted_password = @user.encrypted_password
        new_password = "MyNewPassword"
        put :update, params: {id: @user.id, current_password: @user.password, new_password: new_password}
        @user.reload
        response.should be_success
        @user.encrypted_password.should_not eq(old_encrypted_password)
      end

    end
  end

  describe 'POST #update_from_email' do
    include Docs::V0::Passwords::UpdateFromEmail
    context 'POST /update_from_email', :dox do
      before :each do
        valid_exp = (Time.now + 1.day).to_i
        invalid_exp = (Time.now - 1.day).to_i
        aa = ActorAddress.create_for_user @user, client_metadata: "test"
        restrict_to = 'password reset'
        @password_token = aa.current_token(exp: valid_exp, restrict_to: restrict_to).to_jwt
        #@base_controller.create_token @user valid_exp, restrict_to
        @expired_password_token = aa.current_token(exp: invalid_exp, restrict_to: restrict_to).to_jwt
      end

      it 'should not update a user password if token is not present' do
        post :update_from_email, params: {id: @user.id, password: 'SomeNewPassword'}
        response.should_not be_success
      end

      it 'should update a user password if a valid token is present' do
        post :update_from_email, params: {id: @user.id, password: 'SomeNewPassword', token: @password_token}
        response.should be_success
      end

      it 'should not update if password is too short' do
        post :update_from_email, params: {id: @user.id, password: 'a', token: @password_token}
        response.code.should eq("400")
      end

      it 'should not update a user password if valid token has expired' do
        post :update_from_email, params: {id: @user.id, password: 'SomeNewPassword', token: @expired_password_token}
        response.should_not be_success
      end

    end
  end

  describe 'POST #send_reset_email' do
    include Docs::V0::Passwords::SendResetEmail
    context 'POST /send_reset_email', :dox do
      it 'should send a password reset email' do
        post :send_reset_email, params: {email: @user.email}
        response.should be_success
      end

      it 'should return an error if user does not exist for email provided' do
        post :send_reset_email, params: {email: 'some_random@email.com'}
        response.should_not be_success
      end
    end
  end
end
