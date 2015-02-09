describe Api::V0::PasswordsController do

  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
  end

  context 'PATCH /update' do

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

  context 'POST /reset' do
    it 'should send a password reset email' do
      post :reset, email: @user.email
      response.should be_success
    end
  end

end