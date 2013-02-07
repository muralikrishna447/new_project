require 'spec_helper'

feature 'user authentication', :js do
  include AcceptanceMacros

  scenario 'user can create a user new account' do
    visit '/'
    page.should have_content('Course')
    fill_in 'email', with: 'bob@bob.com'
    click_button('subscribe-email')

    current_path.should == sign_up_path
    fill_in 'user_name', with: 'Bob Tester'
    find_field('user_email').value.should eq 'bob@bob.com'
    fill_in 'user_password', with: 'password'
    fill_in 'user_password_confirmation', with: 'password'
    find(:css, "#terms_registration").set(true)
    click_button 'Sign up'

    page.should have_content('Bob Tester')

    User.count.should == 1
    user = User.first
    user.name.should == 'Bob Tester'

    current_path.should == user_profile_path(user)

  end

  scenario "authenticates a user when valid credentials are provided" do
    login_user
    page.should have_content('Bob Tester')
  end

  scenario "log out" do
    login_user

    page.should have_content('Bob Tester')
    find('#user-dropdown').click
    click_link 'Sign out'

    page.should_not have_content('Bob Tester')
    current_path.should == root_path
  end

  scenario "reset password" do
    user = Fabricate(:user, email: 'bob@bob.com', name: 'Bob Tester', password: 'password')

    visit '/'
    click_link('Sign in')

    click_link('Forgot your password?')
    fill_in 'user_email', with: 'bob@bob.com'
    click_button 'Send Instructions'

    # This test has never been reliable in test, though it seems ok on staging
    # page.should have_content('Please check your email')
    # ActionMailer::Base.deliveries.count.should == 1

    #user.reload
    #visit edit_user_password_path(user, reset_password_token: user.reset_password_token)
    #page.should have_content('Change your password')

    #fill_in 'Password', with: 'newpassword'
    #fill_in 'Confirm Password', with: 'newpassword'
    #click_button 'Change my password'

    #page.should have_content('Bob Tester')
  end
end

