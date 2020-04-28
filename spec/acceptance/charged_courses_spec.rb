require 'spec_helper'
include AcceptanceMacros
Capybara.default_max_wait_time = 15

feature 'charge for classes', pending: true, :js => true do
  let!(:assembly) { Fabricate(:assembly, title: "Clummy", assembly_type: "Course", price: 147.47, published: true ) }
  let!(:landing_page) { Fabricate(:page, title: "Clummy LP", content: "You so clummy", primary_path: "/classes/clummy") }
  let(:current_user) { User.find(1) }

  # Madness from http://artsy.github.io/blog/2012/02/03/reliably-testing-asynchronous-ui-w-slash-rspec-and-capybara/
  # But it does seem to help.
  # Maybe force codeship to rebuild.
  def wait_for_dom(timeout = Capybara.default_wait_time)
    uuid = 'X' + SecureRandom.uuid.split('-')[0]
    page.find("body")
    page.evaluate_script <<-EOS
      _.defer(function() {
        $('body').append("<div id='#{uuid}'></div>");
      });
    EOS
    page.find("##{uuid}")
  end

  def enrollment_should_fail(extra_msg = nil)
    page.find('#complete-buy').click
    wait_for_dom()
    page.should_not have_content('processing your card')
    page.should_not have_content('Thank you for your purchase')
    page.should have_content(extra_msg) if extra_msg
    Enrollment.where(enrollable_type: "Assembly", enrollable_id: assembly.id, user_id: current_user.id).count.should == 0
  end

  def enrollment_should_win
    page.find('#complete-buy').click
    wait_for_dom()
    page.should_not have_content('processing your card')
    wait_for_dom()
    page.should have_content('Thank you for your purchase')
    e = Enrollment.where(enrollable_type: "Assembly", enrollable_id: assembly.id, user_id: current_user.id)
    e.count.should == 1
    e.first.price.should == assembly.price
    current_user.stripe_id.should_not == nil
  end

  def gift_should_win
    page.find('#complete-buy').click
    wait_for_dom()
    page.should_not have_content('processing your card')
    wait_for_dom()
    page.should have_content('Thank you for giving')
    e = GiftCertificate.all
    e.count.should == 1
    e.first.price.should == assembly.price
    current_user.stripe_id.should_not == nil
  end

  describe "With a logged out user" do
    before(:each) do
      visit '/classes/clummy/landing'
      page.should have_content('147.47')
      page.find('#buy-button').click
    end

    scenario "Should get a chance to sign in with nice message" do
      current_path.should == '/sign_in'
      page.should have_content('before enrolling in a course')
    end

    scenario "Should redirect back to course after signin" do
      current_path.should == '/sign_in'
      page.should have_content('before enrolling in a course')
      Fabricate(:user, email: 'bob@bob.com', name: 'Bob Tester', password: 'password')
      fill_in 'user_email', with: 'bob@bob.com'
      fill_in 'user_password', with: 'password'
      click_button 'Sign in'
      current_path.should == '/classes/clummy/landing'
    end

    # TODO should also test redirect after sign up
  end

  describe "With a logged in user" do

    describe "regular purchase" do

      before(:each) do
        login_user
        #session[:coupon] = "'a1b71d389a50'"
        visit '/classes/clummy/landing'
        page.should have_content('147.47')
        #page.should_have_content('71.84')
        page.find('#buy-button').click
      end

      scenario "Cancel button should get rid of charge modal" do
        page.find('#cancel-charge').click
        wait_for_dom()
        page.should_not have_content('CVC')
      end

      scenario "Logged in  user gets error when making various errors on card form" do
        enrollment_should_fail

        fill_in 'cardholder_name', with: "Fancy Pants"
        fill_in 'card_number', with: "4242424242424241"
        fill_in 'expMonth', with: "07"
        fill_in 'expYear', with: "20"
        fill_in 'cvc', with: "777"
        enrollment_should_fail

        fill_in 'card_number', with: "4242424242424242"
        fill_in 'expYear', with: ""
        enrollment_should_fail

        fill_in 'expMonth', with: "07"
        fill_in 'expYear', with: "20"
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
        fill_in 'expMonth', with: "07"
        fill_in 'expYear', with: "20"
        fill_in 'cvc', with: "777"
        enrollment_should_win

        visit '/classes/clummy/landing'
        page.should_not have_content('Buy Now')
        page.should have_content('Continue Class')
      end
    end

    describe "gift purchase" do

      before(:each) do
        login_user
        visit '/classes/clummy/landing'
        page.should have_content('147.47')
        page.find('#gift-button').click
      end

      scenario "Logged in user can buy gift certificate" do
        fill_in 'recipient_name', with: "Smarmy Pants"
        fill_in 'recipient_email', with: "smarmy@pants.com"
        fill_in 'recipient_message', with: "You go on girl"
        page.find('#next-button').click
        wait_for_dom()
        fill_in 'cardholder_name', with: "Fancy Pants"
        fill_in 'card_number', with: "4242424242424242"
        fill_in 'expMonth', with: "07"
        fill_in 'expYear', with: "20"
        fill_in 'cvc', with: "777"
        gift_should_win

        visit '/classes/clummy/landing'
        page.should have_content('Send As Gift')
        page.should have_content('BUY NOW')
      end
    end

    scenario "Paywall should work" do
      visit '/classes/clummy'
      current_path.should == '/classes/clummy/landing'
      login_user
      visit '/classes/clummy'
      current_path.should == '/classes/clummy/landing'
    end
  end
end

feature 'free courses', pending: true, js: true do
  let!(:assembly) { Fabricate :assembly, title: 'Free Course', assembly_type: 'Course', published: true }

  describe 'when logged in' do
    before :each do
      login_user
      visit '/classes/free-course/landing'
      page.should have_content('Enroll For Free')
    end

    scenario 'user should be able to enroll into a free course' do
      page.find('#enroll-free-button').click
      page.should have_content('Continue Class')
    end
  end
end

# Redirect to buy from assembly if not signed in or not enrolled

