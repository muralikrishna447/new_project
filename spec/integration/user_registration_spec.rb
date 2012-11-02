require 'spec_helper'

describe 'User registration application' do

  it "creates a user when valid inputs are supplied" do
    visit '/'
    click_link 'Sign up'
    fill_in 'Name', with: 'Bob'
    fill_in 'Email', with: 'bob@bob.com'
    fill_in 'Password', with: 'password'
    fill_in 'Confirm Password', with: 'password'
    click_button 'Log in'

    User.all.should have(1).users
    User.first.name.should == 'Bob'
  end

end
