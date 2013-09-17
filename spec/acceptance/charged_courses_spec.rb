require 'spec_helper'
include AcceptanceMacros
Capybara.default_wait_time = 10

feature 'charge for courses', :js => true do
  let!(:assembly) { Fabricate(:assembly, title: "Clummy", assembly_type: "Course", price: 147.47, published: true ) }
  let!(:landing_page) { Fabricate(:page, title: "Clummy LP", content: "You so clummy", primary_path: "/courses/clummy") }
  let(:current_user) { User.find(1) }

  describe "With a logged out user" do
    before(:each) do 
      visit '/courses/clummy/landing'
      page.should have_content('147.47')
      page.find('#buy-button').click
    end

    scenario "Should get a chance to sign in with nice message" do
      current_path.should == '/sign_in'
      page.should have_content('before purchasing a course')
    end 

    scenario "Should redirect back to course after signin" do
      current_path.should == '/sign_in'
      page.should have_content('before purchasing a course')
      Fabricate(:user, email: 'bob@bob.com', name: 'Bob Tester', password: 'password')
      fill_in 'user_email', with: 'bob@bob.com'
      fill_in 'user_password', with: 'password'
      click_button 'Sign in'      
      current_path.should == '/courses/clummy/landing'
    end 

    # TODO should also test redirect after sign up
  end

  describe "With a logged in user" do

    before(:each) do 
      login_user
      visit '/courses/clummy/landing'
      page.should have_content('147.47')
      page.find('#buy-button').click
    end

    def enrollment_should_fail(extra_msg = nil) 
      page.find('#complete-buy').click
      page.should have_content('Please fix errors')
      page.should have_content(extra_msg) if extra_msg
      Enrollment.where(enrollable_type: "Assembly", enrollable_id: assembly.id, user_id: current_user.id).count.should == 0
    end

    def enrollment_should_win
      page.find('#complete-buy').click
      page.should_not have_content('processing your card')
      page.should have_content('Thank you for your purchase!')
      e = Enrollment.where(enrollable_type: "Assembly", enrollable_id: assembly.id, user_id: current_user.id)
      e.count.should == 1
      e.first.price.should == assembly.price
      current_user.stripe_id.should_not == nil
    end

    scenario "Cancel button should get rid of charge modal" do
      page.find('#cancel-buy').click
      page.should_not have_content('CVC')
    end
     
    scenario "Logged in user gets error when making various errors on card form" do
      enrollment_should_fail

      fill_in 'cardholder_name', with: "Fancy Pants"
      fill_in 'card_number', with: "4242424242424241"
      fill_in 'expiry', with: "07/20"
      fill_in 'cvc', with: "777"
      enrollment_should_fail

      fill_in 'card_number', with: "4242424242424242"
      fill_in 'expiry', with: "07"
      enrollment_should_fail

      fill_in 'expiry', with: "07/15"
      fill_in 'cvc', with: ""
      enrollment_should_fail

      fill_in 'card_number', with: "4000 0000 0000 0010"
      enrollment_should_fail

      fill_in 'cvc', with: "777"
      fill_in 'card_number', with: "4000 0000 0000 0002"
      enrollment_should_fail("Your card was declined")
    end

    scenario "Logged in user can buy course and continue course" do
      fill_in 'cardholder_name', with: "Fancy Pants"
      fill_in 'card_number', with: "4242424242424242"
      fill_in 'expiry', with: "07/20"
      fill_in 'cvc', with: "777"
      enrollment_should_win

      visit '/courses/clummy/landing'
      page.should_not have_content('Buy Now')
      page.should have_content('Continue Course') 
    end
  end

  scenario "Paywall should work" do
    visit '/courses/clummy'
    current_path.should == '/courses/clummy/landing'
    login_user
    visit '/courses/clummy'
    current_path.should == '/courses/clummy/landing'
  end
end


# Redirect to buy from assembly if not signed in or not enrolled

