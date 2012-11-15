require 'spec_helper'

describe 'User registration application', :js do
  before do
    Version.stub(:current) { 'current version' }
  end

  it "creates a user when valid inputs are supplied" do
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

    page.should have_content('Bob Tester')

    User.all.should have(1).users
    User.first.name.should == 'Bob Tester'
  end

end
