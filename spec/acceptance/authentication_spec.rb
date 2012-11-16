require 'spec_helper'

feature 'user authentication', :js do
  before :all do
    DatabaseCleaner.strategy = :truncation
  end

  after :all do
    DatabaseCleaner.strategy = :transaction
  end

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

  scenario "authenticates a user when valid credentials are provided" do
    Fabricate(:user, email: 'bob@bob.com', name: 'Bob Tester', password: 'password')

    visit '/'
    click_link('Log in')

    wait_until { page.find("#log-in").visible? }

    fill_in 'Email', with: 'bob@bob.com'
    fill_in 'Password', with: 'password'
    click_button 'Log In'

    page.should have_content('Bob Tester')
  end
end

