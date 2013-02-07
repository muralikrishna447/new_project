module AcceptanceMacros
  def login_user
    Fabricate(:user, email: 'bob@bob.com', name: 'Bob Tester', password: 'password')

    visit '/'
    click_link('Sign in')
    current_path.should == sign_in_path

    fill_in 'user_email', with: 'bob@bob.com'
    fill_in 'user_password', with: 'password'
    click_button 'Sign in'

  end
end
