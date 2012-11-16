require 'spec_helper'

feature 'user registration', :js do

  scenario "creates a user when valid inputs are supplied" do
    visit '/'
    click_link('Sign up')

    wait_until { page.find("#sign-up").visible? }

    page.should have_content('Create a new account')

    fill_in 'Name', with: 'Bob Tester'
    fill_in 'Email', with: 'bob@bob.com'
    fill_in 'Password', with: 'password'
    fill_in 'Confirm Password', with: 'password'
    check 'terms-registration'
    click_button 'Sign Up'

    page.should have_content('Thank You Bob Tester')

    User.count.should == 1
    User.first.name.should == 'Bob Tester'
  end

end
