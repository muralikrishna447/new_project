describe Api::V0::PasswordsController do

  before :each do
    Api::V0::BaseController.send(:public, *Api::V0::BaseController.protected_instance_methods)
    @base_controller = Api::V0::BaseController.new
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
  end

  context 'PUT /update' do
    before :each do
      request.env['HTTP_AUTHORIZATION'] = @base_controller.create_token @user
    end

    it 'should not update a user password if current password is not correct' do
      put :update, {id: @user.id, current_password: 'SomeWrongPassword', new_password: 'SomeNewPassword'}
      response.should_not be_success
    end

    it 'should update a users password' do
      old_encrypted_password = @user.encrypted_password
      new_password = "MyNewPassword"
      put :update, {id: @user.id, current_password: @user.password, new_password: new_password}
      @user.reload
      response.should be_success
      @user.encrypted_password.should_not eq(old_encrypted_password)
    end

  end

  context 'PUT /update_from_reset' do
    before :each do
      valid_exp = ((Time.now + 1.day).to_f * 1000).to_i
      invalid_exp = ((Time.now - 1.day).to_f * 1000).to_i
      @password_token = @base_controller.create_token @user, valid_exp, 'Password Reset'
      @expired_password_token = @base_controller.create_token @user, invalid_exp, 'Password Reset'
    end

    it 'should not update a user password if token is not present' do
      put :update_from_reset, {id: @user.id, new_password: 'SomeNewPassword'}
      response.should_not be_success
    end

    it 'should update a user password if a valid token is present' do
      put :update_from_reset, {id: @user.id, new_password: 'SomeNewPassword', token: @password_token}
      response.should be_success
    end

    it 'should not update a user password if valid token has expired' do
      put :update_from_reset, {id: @user.id, new_password: 'SomeNewPassword', token: @expired_password_token}
      response.should_not be_success
    end
  end

  context 'POST /reset' do
    it 'should send a password reset email' do
      post :reset, email: @user.email
      response.should be_success
    end
  end

end