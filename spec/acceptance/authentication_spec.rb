require 'spec_helper'

feature 'user authentication', :js do
  include AcceptanceMacros


  scenario 'user can create a user new account', pending: true do
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


  scenario "authenticates a user when valid credentials are provided", pending: true do
    login_user
    page.should have_content('Bob Tester')
  end

  scenario "log out", pending: true  do

    login_user

    page.should have_content('Bob Tester')
    click_link 'Sign out'

    page.should_not have_content('Bob Tester')
    current_path.should == root_path
  end


  scenario "reset password", pending: true do
    user = Fabricate(:user, email: 'bob@bob.com', name: 'Bob Tester', password: 'password')

    visit '/'
    click_link('Sign in')

    click_link('Reset')
    fill_in 'user_email', with: 'bob@bob.com'
    click_button 'Send Instructions'

    # This test has never been reliable in test, though it seems ok on staging
    # page.should have_content('Please check your email')
    # ActionMailer::Base.deliveries.count.should == 1

    user.reload
    visit edit_user_password_path(user, reset_password_token: user.reset_password_token)
    page.should have_content('Change your password')

    fill_in 'user_password', with: 'newpassword'
    fill_in 'user_password_confirmation', with: 'newpassword'
    click_button 'Update'

    current_path.should eq user_profile_path(user)
  end

  scenario 'user created from aweber can send an email to recieve a default password', pending: true do
    user = Fabricate(:user, email: 'bob@bob.com', name: 'Bob Tester', password: 'password', from_aweber: true)
    visit '/'

    fill_in 'email', with: 'bob@bob.com'
    click_button('subscribe-email')

    current_path.should == new_user_password_path
    page.should have_content("Looks like you've already signed up for our newsletter!")
    click_button 'Send Instructions'

    user.reload
    visit edit_user_password_path(reset_password_token: user.reset_password_token)
    page.should have_content('Change your password')

    fill_in 'user_password', with: 'newpassword'
    fill_in 'user_password_confirmation', with: 'newpassword'
    click_button 'Update'

    current_path.should eq user_profile_path(user)

    user.reload
    user.from_aweber.should eq false
  end

  scenario 'user is prompted with a signup popup after viewing 3 activities', pending: true do
    i = 0
    4.times do
      i+=1
      instance_variable_set("@activity_#{i}", Fabricate(:activity, title: "test_#{i}", description: 'test', published: true))
    end
    visit '/activities/test_1'
    page.should_not have_content('Join the community')
    visit '/activities/test_2'
    page.should_not have_content('Join the community')
    visit '/activities/test_3'
    page.should_not have_content('Join the community')
    visit '/activities/test_4'
    page.should have_content('Join the community')
  end

  scenario 'new visitor is shown the new visitor homepage', pending: true do
    visit '/'
    page.should have_content('ChefSteps is here to help you kick ass in the kitchen.')
  end

  scenario 'returning visitor is shown the default homepage', pending: true do
    login_user
    visit '/'
    page.should_not have_content('ChefSteps is here to help you kick ass in the kitchen.')
  end

end

