require 'spec_helper'

feature 'translation', :js => true do
  scenario "element with id='google_translate_element' is present" do
    activity = Fabricate(:activity, title:'Horseradish Cream', description:'Horseradish cream is so delicious!', published:true)
    DISQUS_SHORTNAME = "delvestaging"
    visit activity_path(activity)
    page.should have_content('Horseradish')
    wait_until { page.find('#google_translate_element').visible? }
    page.find('.goog-te-gadget-simple').visible?
    page.find('.goog-te-menu-frame').visible?
    page.find('.goog-te-gadget').visible?
    page.find('span#beta-notification').visible?
    page.find('.goog-te-menu-value').visible?

    page.find('#language-selector').click

    # The test below only works with the default Selenium test framework.
    # In spec_helper.rb comment out Capybara.javascript_driver = :poltergeist
    # Leave the test below commented out for the production environment 
    # within_frame('language-frame') do
    #   page.find('div.goog-te-menu2').visible?
    #   page.find('a.goog-te-menu2-item').visible?
    # end
  end
  
end