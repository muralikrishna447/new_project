require 'spec_helper'

feature 'charge for courses', pending: false ,:js => true do
  include AcceptanceMacros

  scenario "charge form" do
    login_user
    assembly = Fabricate(:assembly, title: "Clummy", assembly_type: :course, price: 147.47, published: true )
    landing_page = Fabricate(:page, title: "Clummy LP", content: "You so clummy", primary_path: "/courses/clummy")
    visit '/courses/clummy/landing'
    puts page.inspect
    page.should have_content('147.47')
    page.find('#buy-button').click
    save_and_open_page
    fill_in 'cardholder_name', with: "Fancy Pants"
    fill_in 'card_number', with: "4242424242424242"
    fill_in 'expiry', with: "07/20"
    fill_in 'cvc', with: "777"
    page.find('#complete-buy').click
    page.should have_content('Thank you for your purchase!')
    save_and_open_page
  end
end

# To test
# Redirect to buy from assembly if not signed in or not enrolled
# Sign in workflow
# Sign up workflow
# Buy success workflow
# Buy fail workflow
# Continue course workflow