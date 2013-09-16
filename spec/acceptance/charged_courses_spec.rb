require 'spec_helper'
include AcceptanceMacros

feature 'charge for courses', :js => true do
  let!(:assembly) { Fabricate(:assembly, title: "Clummy", assembly_type: :course, price: 147.47, published: true ) }
  let!(:landing_page) { Fabricate(:page, title: "Clummy LP", content: "You so clummy", primary_path: "/courses/clummy") }
  let(:current_user) { User.find(1) }

  before(:each) do 
    login_user
    visit '/courses/clummy/landing'
    page.should have_content('147.47')
    page.find('#buy-button').click
  end

  def enrollment_should_fail 
    page.find('#complete-buy').click
    page.should have_content('Please fix errors')
    Enrollment.where(enrollable_type: "Assembly", enrollable_id: assembly.id, user_id: current_user.id).count.should == 0
  end

  def enrollment_should_win
    page.find('#complete-buy').click
    page.should have_content('Thank you for your purchase!')
    e = Enrollment.where(enrollable_type: "Assembly", enrollable_id: assembly.id, user_id: current_user.id)
    e.count.should == 1
    e.first.price.should == assembly.price
    current_user.stripe_id.should_not == nil
  end
   
  scenario "Logged in user gets error when making various errors on card form" do
    fill_in 'cardholder_name', with: "Fancy Pants"
    fill_in 'card_number', with: "4242424242424241"
    fill_in 'expiry', with: "07/20"
    fill_in 'cvc', with: "777"
    enrollment_should_fail
  end

  scenario "Logged in user can buy course" do
    fill_in 'cardholder_name', with: "Fancy Pants"
    fill_in 'card_number', with: "4242424242424242"
    fill_in 'expiry', with: "07/20"
    fill_in 'cvc', with: "777"
    enrollment_should_win
  end
end

# To test
# Redirect to buy from assembly if not signed in or not enrolled
# Sign in workflow
# Sign up workflow
# Buy success workflow
# Buy fail workflow
# Continue course workflow