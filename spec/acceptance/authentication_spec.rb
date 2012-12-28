require 'spec_helper'

feature 'user authentication', :js do
  include AcceptanceMacros

  scenario "creates a user when valid inputs are supplied and takes user to edit profile page" do
    visit '/'
    page.should have_content('Shop')
    click_link('Sign up')

    wait_until { page.find("#sign-up").visible? }

    page.should have_content('Create a new account')

    fill_in 'Name', with: 'Bob Tester'
    fill_in 'Email', with: 'bob@bob.com'
    fill_in 'Password', with: 'password'
    fill_in 'Confirm Password', with: 'password'
    check 'terms-registration'
    click_button 'Sign Up'

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

  scenario "reset password" do
    user = Fabricate(:user, email: 'bob@bob.com', name: 'Bob Tester', password: 'password')

    visit '/'
    click_link('Log in')

    wait_until { page.find("#log-in").visible? }
    click_link('Forgot your password?')
    fill_in 'Email', with: 'bob@bob.com'
    click_button 'Send Instructions'

    # wait_until { page.find('.notice').visible? }
    page.should have_content('Please check your email')
    ActionMailer::Base.deliveries.count.should == 1

    user.reload
    visit edit_user_password_path(user, reset_password_token: user.reset_password_token)
    page.should have_content('Change your password')

    fill_in 'Password', with: 'newpassword'
    fill_in 'Confirm Password', with: 'newpassword'
    click_button 'Change my password'

    page.should have_content('Bob Tester')
  end

  scenario "log out" do
    login_user

    page.should have_content('Bob Tester')

    click_link 'Log out'

    page.should_not have_content('Bob Tester')
    current_path.should == root_path
  end
end

